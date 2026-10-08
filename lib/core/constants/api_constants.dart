class ApiConstants {
  static const String baseUrl = 'http://localhost:3000';
  static const String apiVersion = '/api';
  
  static const String register = '$apiVersion/auth/register';
  static const String login = '$apiVersion/auth/login';
  static const String google = '$apiVersion/auth/google';
  static const String verifyEmail = '$apiVersion/auth/verify-email';
  static const String resendOtp = '$apiVersion/auth/resend-otp';
  static const String me = '$apiVersion/auth/me';
  static const String updateProfile = '$apiVersion/auth/me';
  static const String changePassword = '$apiVersion/auth/change-password';
  static const String forgotPassword = '$apiVersion/auth/forgot-password';
  static const String resetPassword = '$apiVersion/auth/reset-password';
  
  static const String books = '$apiVersion/books';
  static const String bookReviews = '$apiVersion/books';
  
  static const String cart = '$apiVersion/cart';
  static const String cartItems = '$apiVersion/cart/items';
  
  static const String wishlist = '$apiVersion/wishlist';
  
  static const String orders = '$apiVersion/orders';
  
  static const String adminSummary = '$apiVersion/admin/summary';
  static const String adminBooks = '$apiVersion/admin/books';
  static const String adminOrders = '$apiVersion/admin/orders';
  static const String adminUsers = '$apiVersion/admin/users';
}