class RuntimeConfig {
  // Runtime configuration that can be set from JavaScript
  static String _baseUrl = 'https://pms-backend-qeq7.onrender.com';
  
  static String get baseUrl => _baseUrl;
  
  static void setBaseUrl(String url) {
    _baseUrl = url;
  }
  
  // Force runtime URL override
  static void initialize() {
    // This will be called from main.dart to ensure correct URL
    _baseUrl = 'https://pms-backend-qeq7.onrender.com';
  }
}
