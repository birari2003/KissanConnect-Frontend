class ApiConfig {
  ApiConfig._();

  static String _environment = 'production';
  static const String _localBaseUrl = 'http://192.168.43.43:5000';
  static const String _productionBaseUrl =
      'https://kissanconnect-backend-z00d.onrender.com';

  static void initialize(String environment) {
    if (environment != 'local' && environment != 'production') {
      throw ArgumentError('Environment must be either "local" or "production"');
    }
    _environment = environment;
    print('🌐 API Environment set to: $_environment');
    print('📡 Base URL: ${getBaseUrl()}');
  }

  static String get environment => _environment;

  static String getBaseUrl() {
    return _environment == 'local' ? _localBaseUrl : _productionBaseUrl;
  }

  static String get farmerBaseUrl => '${getBaseUrl()}/farmer';

  static String get adminBaseUrl => '${getBaseUrl()}/admin';

  static String get paymentBaseUrl => '${getBaseUrl()}/payment';

  static String getUploadUrl(String filePath) {
    final cleanPath = filePath.startsWith('/')
        ? filePath.substring(1)
        : filePath;
    return '${getBaseUrl()}/uploads/$cleanPath';
  }

  static bool get isLocal => _environment == 'local';

  static bool get isProduction => _environment == 'production';
}
