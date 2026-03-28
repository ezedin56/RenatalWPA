const axios = require('axios');

const BASE_URL = 'https://apisandbox.safaricom.et';

// Cache token in memory to avoid fetching on every request
let _cachedToken = null;
let _tokenExpiry = 0;

/**
 * Generate OAuth access token using Basic auth (consumer key:secret)
 */
const getAccessToken = async () => {
    if (_cachedToken && Date.now() < _tokenExpiry) return _cachedToken;

    const key = process.env.MPESA_CONSUMER_KEY;
    const secret = process.env.MPESA_CONSUMER_SECRET;
    const auth = Buffer.from(`${key}:${secret}`).toString('base64');

    const { data } = await axios.get(
        `${BASE_URL}/v1/token/generate?grant_type=client_credentials`,
        { headers: { Authorization: `Basic ${auth}` } }
    );

    _cachedToken = data.access_token;
    // Tokens are valid for 1 hour; refresh 5 min early
    _tokenExpiry = Date.now() + (55 * 60 * 1000);
    return _cachedToken;
};

/**
 * Generate timestamp in YYYYMMDDHHMMSS format
 */
const getTimestamp = () => {
    const d = new Date();
    const pad = (n) => String(n).padStart(2, '0');
    return `${d.getFullYear()}${pad(d.getMonth() + 1)}${pad(d.getDate())}` +
           `${pad(d.getHours())}${pad(d.getMinutes())}${pad(d.getSeconds())}`;
};

/**
 * Generate Base64 password: shortcode + passkey + timestamp
 */
const getPassword = (timestamp) => {
    const shortCode = process.env.MPESA_BUSINESS_SHORT_CODE;
    const passKey = process.env.MPESA_PASS_KEY;
    return Buffer.from(`${shortCode}${passKey}${timestamp}`).toString('base64');
};

/**
 * STK Push (C2B) — prompts customer phone with PIN dialog
 * @param {string} phone  - customer phone e.g. 251777564882
 * @param {number} amount - amount in ETB
 * @param {string} accountRef - e.g. transaction reference
 * @param {string} description - short description
 */
const stkPush = async (phone, amount, accountRef, description = 'Payment') => {
    const token = await getAccessToken();
    const timestamp = getTimestamp();
    const password = getPassword(timestamp);
    const shortCode = process.env.MPESA_BUSINESS_SHORT_CODE;

    const payload = {
        MerchantRequestID: `HouseRental-${Date.now()}`,
        BusinessShortCode: shortCode,
        Password: password,
        Timestamp: timestamp,
        TransactionType: 'CustomerPayBillOnline',
        Amount: Math.round(amount),
        PartyA: phone,
        PartyB: shortCode,
        PhoneNumber: phone,
        CallBackURL: process.env.MPESA_CALLBACK_URL,
        AccountReference: accountRef,
        TransactionDesc: description,
    };

    const { data } = await axios.post(
        `${BASE_URL}/mpesa/stkpush/v3/processrequest`,
        payload,
        { headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' } }
    );

    return data; // { MerchantRequestID, CheckoutRequestID, ResponseCode, ResponseDescription, CustomerMessage }
};

/**
 * B2C — send money from business to customer (payouts / refunds)
 */
const b2cPayment = async (phone, amount, remarks = 'Payout', occasion = 'PayOut') => {
    const token = await getAccessToken();

    const payload = {
        OriginatorConversationID: `HouseRental-B2C-${Date.now()}`,
        InitiatorName: process.env.MPESA_B2C_INITIATOR_NAME,
        SecurityCredential: process.env.MPESA_B2C_SECURITY_CREDENTIAL,
        CommandID: 'BusinessPayment',
        PartyA: process.env.MPESA_BUSINESS_SHORT_CODE,
        PartyB: phone,
        Amount: Math.round(amount),
        Remarks: remarks,
        Occassion: occasion,
        QueueTimeOutURL: process.env.MPESA_CALLBACK_URL,
        ResultURL: process.env.MPESA_CALLBACK_URL,
    };

    const { data } = await axios.post(
        `${BASE_URL}/mpesa/b2c/v2/paymentrequest`,
        payload,
        { headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' } }
    );

    return data;
};

/**
 * Reversal — reverse a completed C2B transaction
 */
const reverseTransaction = async (transactionId, amount, receiverParty, remarks = 'Reversal') => {
    const token = await getAccessToken();

    const payload = {
        OriginatorConversationID: `HouseRental-REV-${Date.now()}`,
        Initiator: process.env.MPESA_B2C_INITIATOR_NAME,
        SecurityCredential: process.env.MPESA_B2C_SECURITY_CREDENTIAL,
        CommandID: 'TransactionReversal',
        TransactionID: transactionId,
        Amount: Math.round(amount),
        OriginalConversationID: `AG-${Date.now()}`,
        PartyA: process.env.MPESA_BUSINESS_SHORT_CODE,
        RecieverIdentifierType: '4',
        ReceiverParty: receiverParty,
        ResultURL: process.env.MPESA_CALLBACK_URL,
        QueueTimeOutURL: process.env.MPESA_CALLBACK_URL,
        Remarks: remarks,
        Occasion: 'Reversal',
    };

    const { data } = await axios.post(
        `${BASE_URL}/mpesa/reversal/v2/request`,
        payload,
        { headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' } }
    );

    return data;
};

module.exports = { getAccessToken, stkPush, b2cPayment, reverseTransaction };
