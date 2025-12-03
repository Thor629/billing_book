class AppConfig {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:8000/api';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshEndpoint = '/auth/refresh';

  // Admin Endpoints
  static const String adminUsersEndpoint = '/admin/users';
  static const String adminPlansEndpoint = '/admin/plans';
  static const String adminActivityLogsEndpoint = '/admin/activity-logs';

  // User Endpoints
  static const String userProfileEndpoint = '/user/profile';
  static const String userSubscriptionEndpoint = '/user/subscription';
  static const String plansEndpoint = '/plans';
  static const String subscribeEndpoint = '/user/subscribe';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Pagination
  static const int defaultPageSize = 20;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
