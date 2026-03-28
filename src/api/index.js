import api from './client';

// Auth
export const loginAdmin = (email, password) =>
  api.post('/auth/login', { email, password });

// Dashboard
export const getStats = () => api.get('/admin/stats');
export const getAnalytics = () => api.get('/admin/analytics/users');

// Users
export const getUsers = (params) => api.get('/admin/users', { params });
export const getPendingUsers = () => api.get('/admin/users/pending');
export const approveUser = (id) => api.put(`/admin/users/${id}/approve`);
export const suspendUser = (id, data) => api.put(`/admin/users/${id}/suspend`, data);
export const deleteUser = (id) => api.delete(`/admin/users/${id}`);
export const bulkApproveUsers = (ids) => api.post('/admin/users/bulk-approve', { ids });

// Listings
export const getListings = (params) => api.get('/admin/houses', { params });
export const deleteListing = (id) => api.delete(`/admin/houses/${id}`);
export const flagListing = (id, data) => api.put(`/admin/houses/${id}/flag`, data);

// Payments
export const initiateStkPush = (phoneNumber, amount, type) =>
  api.post('/payment/stk-push', { phoneNumber, amount, type });
export const getPaymentStatus = (transactionId) =>
  api.get(`/payment/status/${transactionId}`);
export const upgradePremium = (transactionId) =>
  api.post('/premium/upgrade', { transactionId });
export const b2cPayout = (phoneNumber, amount, remarks) =>
  api.post('/payment/b2c', { phoneNumber, amount, remarks });
export const reversePayment = (data) =>
  api.post('/payment/reverse', data);

// Audit logs
export const getAuditLogs = (params) => api.get('/admin/audit-logs', { params });

// Notifications
export const broadcastNotification = (data) => api.post('/admin/notifications/broadcast', data);

// Transactions
export const getTransactions = (params) => api.get('/admin/transactions', { params });
