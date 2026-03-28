const express = require('express');
const router = express.Router();
const {
    checkLimit,
    initiateStkPush,
    mpesaCallback,
    getPaymentStatus,
    upgradePremium,
    b2cPayout,
    reversePayment,
    getMyTransactions,
} = require('../controllers/paymentController');
const { protect, authorize } = require('../middleware/auth');

// Premium limit check
router.get('/premium/check-limit', protect, authorize('owner', 'broker'), checkLimit);

// STK Push — initiate real M-Pesa payment
router.post('/payment/stk-push', protect, initiateStkPush);

// M-Pesa callback — called by Safaricom (no auth, public)
router.post('/payment/mpesa/callback', mpesaCallback);

// Poll payment status
router.get('/payment/status/:transactionId', protect, getPaymentStatus);

// Activate premium after confirmed payment
router.post('/premium/upgrade', protect, authorize('owner', 'broker'), upgradePremium);

// Admin: B2C payout to customer
router.post('/payment/b2c', protect, authorize('admin'), b2cPayout);

// Admin: reverse a transaction
router.post('/payment/reverse', protect, authorize('admin'), reversePayment);

// User transaction history
router.get('/transactions', protect, getMyTransactions);

module.exports = router;
