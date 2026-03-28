const Transaction = require('../models/Transaction');
const User = require('../models/User');
const House = require('../models/House');
const { stkPush, b2cPayment, reverseTransaction } = require('../utils/mpesa');

// ─── GET /api/v1/premium/check-limit ────────────────────────────────────────
exports.checkLimit = async (req, res, next) => {
    try {
        const [count, user] = await Promise.all([
            House.countDocuments({ listedBy: req.user._id, isActive: true }),
            User.findById(req.user._id),
        ]);
        res.json({
            success: true,
            data: {
                canAddFree: count === 0,
                usedFree: Math.min(count, 1),
                totalListings: count,
                isPremium: user.isPremium,
                requiresPremium: count >= 1 && !user.isPremium,
                premiumExpiry: user.premiumExpiry,
            },
        });
    } catch (err) { next(err); }
};

// ─── POST /api/v1/payment/stk-push ──────────────────────────────────────────
// Initiates real M-Pesa STK Push to customer's phone
exports.initiateStkPush = async (req, res, next) => {
    try {
        const { phoneNumber, amount, type } = req.body;
        if (!phoneNumber || !amount || !type) {
            return res.status(400).json({
                success: false,
                error: { code: 'VALIDATION_001', message: 'phoneNumber, amount and type are required' },
            });
        }
        if (!['premium_upgrade', 'extra_listing'].includes(type)) {
            return res.status(400).json({
                success: false,
                error: { code: 'VALIDATION_002', message: 'type must be premium_upgrade or extra_listing' },
            });
        }

        // Normalise phone: strip leading 0 or + and ensure country code
        const phone = normalisePhone(phoneNumber);

        // Create a pending transaction first so we can match the callback
        const transaction = await Transaction.create({
            userId: req.user._id,
            amount: Number(amount),
            type,
            status: 'pending',
            paymentMethod: 'mpesa',
            mpesaPhone: phone,
        });

        // Fire STK Push
        const mpesaRes = await stkPush(
            phone,
            Number(amount),
            transaction.reference,
            type === 'premium_upgrade' ? 'Premium Upgrade' : 'Extra Listing'
        );

        // Store the CheckoutRequestID so we can match the callback
        transaction.checkoutRequestId = mpesaRes.CheckoutRequestID;
        transaction.merchantRequestId = mpesaRes.MerchantRequestID;
        await transaction.save();

        res.status(201).json({
            success: true,
            message: mpesaRes.CustomerMessage || 'STK Push sent. Enter your M-Pesa PIN.',
            data: {
                transactionId: transaction._id,
                reference: transaction.reference,
                checkoutRequestId: mpesaRes.CheckoutRequestID,
            },
        });
    } catch (err) {
        // Surface M-Pesa API errors clearly
        const mpesaMsg = err.response?.data?.errorMessage || err.response?.data?.ResponseDescription;
        if (mpesaMsg) {
            return res.status(502).json({ success: false, error: { code: 'MPESA_ERROR', message: mpesaMsg } });
        }
        next(err);
    }
};

// ─── POST /api/v1/payment/mpesa/callback ────────────────────────────────────
// Safaricom calls this URL after the customer completes/cancels the STK Push
exports.mpesaCallback = async (req, res) => {
    try {
        const body = req.body?.Body?.stkCallback || req.body;
        const { MerchantRequestID, CheckoutRequestID, ResultCode, ResultDesc, CallbackMetadata } = body;

        const transaction = await Transaction.findOne({ checkoutRequestId: CheckoutRequestID });
        if (!transaction) return res.json({ success: true }); // unknown — ignore

        if (ResultCode === 0) {
            // Success — extract receipt from metadata items
            const items = CallbackMetadata?.Item || [];
            const get = (name) => items.find(i => i.Name === name)?.Value;

            transaction.status = 'completed';
            transaction.receiptNumber = get('MpesaReceiptNumber') || `MPESA${Date.now()}`;
            transaction.mpesaPhone = String(get('PhoneNumber') || transaction.mpesaPhone);
            await transaction.save();

            // Auto-activate premium if that was the payment type
            if (transaction.type === 'premium_upgrade') {
                const expiry = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
                await User.findByIdAndUpdate(transaction.userId, { isPremium: true, premiumExpiry: expiry });
            }
        } else {
            transaction.status = 'failed';
            transaction.failureReason = ResultDesc;
            await transaction.save();
        }

        res.json({ success: true });
    } catch (err) {
        console.error('M-Pesa callback error:', err.message);
        res.json({ success: true }); // always 200 to Safaricom
    }
};

// ─── GET /api/v1/payment/status/:transactionId ──────────────────────────────
// Poll this from the client to check if STK Push was completed
exports.getPaymentStatus = async (req, res, next) => {
    try {
        const transaction = await Transaction.findOne({
            _id: req.params.transactionId,
            userId: req.user._id,
        });
        if (!transaction) {
            return res.status(404).json({ success: false, error: { message: 'Transaction not found' } });
        }
        res.json({ success: true, data: { status: transaction.status, receiptNumber: transaction.receiptNumber } });
    } catch (err) { next(err); }
};

// ─── POST /api/v1/premium/upgrade ───────────────────────────────────────────
// Called after a completed payment to explicitly activate premium
exports.upgradePremium = async (req, res, next) => {
    try {
        const { transactionId } = req.body;
        const transaction = await Transaction.findById(transactionId);
        if (!transaction || transaction.status !== 'completed') {
            return res.status(400).json({
                success: false,
                error: { code: 'PAYMENT_001', message: 'Valid completed transaction required' },
            });
        }
        if (transaction.userId.toString() !== req.user._id.toString()) {
            return res.status(403).json({ success: false, error: { message: 'Transaction does not belong to you' } });
        }
        const expiry = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
        await User.findByIdAndUpdate(req.user._id, { isPremium: true, premiumExpiry: expiry });
        res.json({ success: true, message: 'Premium activated!', data: { premiumExpiry: expiry } });
    } catch (err) { next(err); }
};

// ─── POST /api/v1/payment/b2c ────────────────────────────────────────────────
// Admin-initiated payout to a customer (refund / reward)
exports.b2cPayout = async (req, res, next) => {
    try {
        const { phoneNumber, amount, remarks } = req.body;
        if (!phoneNumber || !amount) {
            return res.status(400).json({
                success: false,
                error: { code: 'VALIDATION_001', message: 'phoneNumber and amount are required' },
            });
        }
        const phone = normalisePhone(phoneNumber);
        const result = await b2cPayment(phone, Number(amount), remarks || 'Payout');
        res.json({ success: true, data: result });
    } catch (err) {
        const mpesaMsg = err.response?.data?.errorMessage;
        if (mpesaMsg) return res.status(502).json({ success: false, error: { message: mpesaMsg } });
        next(err);
    }
};

// ─── POST /api/v1/payment/reverse ────────────────────────────────────────────
// Admin-initiated reversal of a C2B transaction
exports.reversePayment = async (req, res, next) => {
    try {
        const { transactionId, mpesaTransactionId, amount, receiverParty } = req.body;
        if (!mpesaTransactionId || !amount || !receiverParty) {
            return res.status(400).json({
                success: false,
                error: { code: 'VALIDATION_001', message: 'mpesaTransactionId, amount and receiverParty are required' },
            });
        }
        const result = await reverseTransaction(mpesaTransactionId, Number(amount), receiverParty);

        if (transactionId) {
            await Transaction.findByIdAndUpdate(transactionId, { status: 'failed', failureReason: 'Reversed by admin' });
        }

        res.json({ success: true, data: result });
    } catch (err) {
        const mpesaMsg = err.response?.data?.errorMessage;
        if (mpesaMsg) return res.status(502).json({ success: false, error: { message: mpesaMsg } });
        next(err);
    }
};

// ─── GET /api/v1/transactions ────────────────────────────────────────────────
exports.getMyTransactions = async (req, res, next) => {
    try {
        const { page = 1, limit = 20 } = req.query;
        const skip = (Number(page) - 1) * Number(limit);
        const [txns, total] = await Promise.all([
            Transaction.find({ userId: req.user._id }).sort('-createdAt').skip(skip).limit(Number(limit)),
            Transaction.countDocuments({ userId: req.user._id }),
        ]);
        res.json({ success: true, data: txns, pagination: { page: Number(page), limit: Number(limit), total } });
    } catch (err) { next(err); }
};

// ─── Helper ──────────────────────────────────────────────────────────────────
// Normalise Ethiopian phone: 0912... → 251912..., +251... → 251...
function normalisePhone(phone) {
    let p = String(phone).replace(/\s+/g, '');
    if (p.startsWith('+')) p = p.slice(1);
    if (p.startsWith('0')) p = '251' + p.slice(1);
    return p;
}
