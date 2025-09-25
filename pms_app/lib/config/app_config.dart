class AppConfig {
  // Production backend URL (will be set by Render environment variable)
  static const String baseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://pms-backend-qeq7.onrender.com',
  );
  
  // Force rebuild - remove this line after deployment
  static const String buildTag = 'v2.0.0-rebuild';
  
  // API endpoints
  static const String usersEndpoint = '/users';
  static const String ticketsEndpoint = '/tickets';
  static const String publicRequestsEndpoint = '/public/requests';
  static const String lookupsEndpoint = '/lookups';
  static const String eventsEndpoint = '/events/stream';
  static const String healthEndpoint = '/health';
  static const String attachmentsEndpoint = '/attachments';
  
  // App settings
  static const String appName = 'PMS - Project Management System';
  static const String appVersion = '1.0.0';
  
  // Timeout settings
  static const int requestTimeout = 30000; // 30 seconds
  static const int connectionTimeout = 10000; // 10 seconds
  
  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;
  
  // File upload settings
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFileTypes = [
    'pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'gif', 'txt'
  ];
  
  // Debug mode
  static const bool isDebugMode = bool.fromEnvironment('DEBUG', defaultValue: false);
  
  // Logging
  static void log(String message) {
    if (isDebugMode) {
      print('[PMS] $message');
    }
  }
  
  // Error handling
  static String getErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'No internet connection. Please check your network.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    } else if (error.toString().contains('FormatException')) {
      return 'Invalid data format received from server.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}
