class ApiEndpoints {
  // ADB reverse tunnel active — phone reaches PC's localhost via USB
  static const String baseUrl = 'http://localhost:5000/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Houses
  static const String houses = '/houses';
  static const String searchHouses = '/houses/search';
  static String houseById(String id) => '/houses/$id';
  static const String myListings = '/houses/my-listings';

  // Favorites
  static const String favorites = '/favorites';
  static String favoriteById(String houseId) => '/favorites/$houseId';

  // Inquiries
  static const String inquiries = '/inquiries';
  static const String myInquiries = '/inquiries/my-inquiries';
  static const String receivedInquiries = '/inquiries/received';
  static String inquiryById(String id) => '/inquiries/$id';
  static String inquiryReply(String id) => '/inquiries/$id/reply';

  // Payments / Premium
  static const String checkPremiumLimit = '/premium/check-limit';
  static const String upgradePremium = '/premium/upgrade';
  static const String stkPush = '/payment/stk-push';
  static String paymentStatus(String id) => '/payment/status/$id';
  static const String b2cPayout = '/payment/b2c';
  static const String reversePayment = '/payment/reverse';
  static const String transactions = '/transactions';

  // Upload
  static const String uploadImages = '/upload/images';

  // User profile
  static const String updateProfile = '/users/me';
  static const String uploadAvatar = '/users/me/avatar';
}
