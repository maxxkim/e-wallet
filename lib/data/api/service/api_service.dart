// Modified ApiService class with improved certificate pinning implementation
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:zippy/data/api/api_auth_initiate.dart';
import 'package:zippy/data/api/api_auth_refresh.dart';
import 'package:zippy/data/api/api_auth_verify.dart';
import 'package:zippy/data/api/api_balance.dart';
import 'package:zippy/data/api/api_category_responce.dart';
import 'package:zippy/data/api/api_global_search_response.dart';
import 'package:zippy/data/api/api_key_manager.dart';
import 'package:zippy/data/api/api_top_up.dart';
import 'package:zippy/data/api/api_top_up_initiate.dart';
import 'package:zippy/data/api/api_transaction.dart';
import 'package:zippy/data/api/api_transfer_initiate.dart';
import 'package:zippy/data/api/api_verify_token.dart';
import 'package:zippy/data/api/api_withdraw.dart';
import 'package:zippy/data/api/api_withdrawal_initiate.dart';
import 'package:zippy/data/api/interceptors/certificate_pinning_interceptor.dart';
import 'package:zippy/data/api/responcses/activation_responses.dart';
import 'package:zippy/domain/model/auth/country_model.dart';
import 'package:zippy/domain/model/contacts/contact_model.dart';
import 'package:zippy/domain/model/offer/activation_model.dart';
import 'package:zippy/internal/services/logger_service.dart';
import 'package:zippy/internal/services/secure_storage_service.dart';

class ApiService {
  final Dio _dio = Dio();
  final SecureStorageService _secureStorage = SecureStorageService();
  final LoggerService _logger = LoggerService();
  final SecureApiKeyManager _apiKeyManager = SecureApiKeyManager();

  // Flag to track initialization status
  bool _isInitialized = false;

  // Maximum retry attempts for API key issues
  static const int _maxApiKeyRetries = 3;
  // Define hosts for certificate pinning - all the microservices
  static const List<String> _pinnedHosts = [
    'balance-service-zug9v.ondigitalocean.app',
    'trx-service-lc9l6.ondigitalocean.app',
    'auth-service-9jf3q.ondigitalocean.app',
    'transfer-service-dibxk.ondigitalocean.app',
    'contact-service-w42s8.ondigitalocean.app',
    'merchant-service-gp4xz.ondigitalocean.app',
    'offer-service-xn3b9.ondigitalocean.app',
    'search-service-52g7l.ondigitalocean.app'
  ];

  // Certificate pins for the hosts
  static const List<String> _certificatePins = [
    'sha256/qLTRfjRmkUcjDm/VzK9yWYYsxcAJ75/OOlIKiaG8uCw=',
    'sha256/YZPgTZ+woNCCCIW3LH2CxQeLzB/1m42QcCTBSdgayjs=',
  ];

  ApiService() {
    _initializeService();
  }

  Future<void> _initializeService() async {
    _logger.kawaii('🚀 Starting ApiService initialization~!');

    // Initialize API key manager first
    bool keysInitialized = await _apiKeyManager.initialize();

    if (!keysInitialized) {
      _logger.error(
          '❌ Failed to initialize API keys! Service will not function properly >.<');
      _isInitialized = false;
      return;
    }

    // Configure interceptors, certificate pinning etc.
    _configureInterceptors();
    _configureCertificatePinning();

    _isInitialized = true;
    _logger.kawaii(
        '✨ ApiService initialized with secure API keys! Ready to nyaa~ ✨');
  }

  void _configureCertificatePinning() {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        final pinner = CertificatePinner();
        pinner.configureDio(_dio, _certificatePins, _pinnedHosts);
        _logger
            .kawaii('🔒 Certificate pinning configured successfully! Nyaa~ 🔐');
      } catch (e) {
        _logger.error('❌ Failed to configure certificate pinning: $e');
      }
    } else {
      _logger.warning(
          '⚠️ Certificate pinning is only configured for Android and iOS platforms.');
    }
  }

  Future<void> handleApiKeyError(
      DioException error, ErrorInterceptorHandler handler,
      {int retryCount = 0}) async {
    // Avoid infinite retry loops
    if (retryCount >= _maxApiKeyRetries) {
      _logger.critical(
          '💔 Maximum API key retry attempts reached. Request will fail.');
      return handler.next(error);
    }

    _logger.warning(
        '🔑 API key issue detected! Attempting to recover... [Attempt ${retryCount + 1}/${_maxApiKeyRetries}]');

    try {
      // Clear the current API key
      await _apiKeyManager.removeApiKey(SecureApiKeyManager.kMainApiKey);

      // Re-initialize from assets
      final bool success = await _apiKeyManager.initialize();

      if (!success) {
        _logger.error('❌ Failed to recover API key from assets');
        return handler.next(error);
      }

      // Get the new API key
      final String? newApiKey =
          await _apiKeyManager.getApiKey(SecureApiKeyManager.kMainApiKey);

      if (newApiKey == null || newApiKey.isEmpty) {
        _logger.error('❌ Failed to get new API key after re-initialization');
        return handler.next(error);
      }

      // Retry the request with the new API key
      _logger.info('🔄 Retrying request with new API key');
      error.requestOptions.headers['x-api-key'] = newApiKey;

      final opts = Options(
        method: error.requestOptions.method,
        headers: error.requestOptions.headers,
      );

      final response = await _dio.request(
        error.requestOptions.path,
        options: opts,
        data: error.requestOptions.data,
        queryParameters: error.requestOptions.queryParameters,
      );

      return handler.resolve(response);
    } catch (e) {
      _logger.error('❌ Failed to recover from API key error: $e');

      // Try one more time with incremented retry count
      if (retryCount < _maxApiKeyRetries - 1) {
        return await handleApiKeyError(error, handler,
            retryCount: retryCount + 1);
      }

      return handler.next(error);
    }
  }

  void _configureInterceptors() {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: false,
          printResponseHeaders: false,
          printResponseMessage: false,
          printResponseData: false,
          printRequestData: false,
        ),
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!_isInitialized || !_apiKeyManager.isInitialized) {
            _logger.error(
                '❌ API service not properly initialized! Cannot make requests >.<');

            // Try to initialize again
            await _apiKeyManager.initialize();

            if (!_apiKeyManager.isInitialized) {
              // If still not initialized, reject the request
              return handler.reject(
                DioException(
                  requestOptions: options,
                  error:
                      'API service not properly initialized. Missing API keys.',
                  type: DioExceptionType.unknown,
                ),
              );
            }
          }

          // Get the API key
          final String? apiKey =
              await _apiKeyManager.getApiKey(SecureApiKeyManager.kMainApiKey);

          if (apiKey == null || apiKey.isEmpty) {
            _logger
                .error('❌ No valid API key available! Request will fail >.<');
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'No valid API key available',
                type: DioExceptionType.unknown,
              ),
            );
          }
          // Add API key to headers
          options.headers['x-api-key'] = apiKey;
          _logger.debug('🔑 Added secure API key to request headers');

          String? accessToken = await _secureStorage.getAccessToken();
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          _logger
              .warning('⚠️ API error occurred: ${error.response?.statusCode}');

          // Handle API Key errors
          if (error.response?.statusCode == 401 &&
              error.response?.data['message'] == 'Invalid API key') {
            return await handleApiKeyError(error, handler);
          }

          // Handle token refresh as before
          if (error.response?.statusCode == 401) {
            try {
              String? refreshToken = await _secureStorage.getRefreshToken();
              if (refreshToken != null) {
                final response = await _dio.post(
                  'https://auth-service-9jf3q.ondigitalocean.app/auth/refresh',
                  data: {
                    'refreshToken': refreshToken,
                  },
                );
                final refreshResponse = response.data;
                if (refreshResponse['accessToken'] != null) {
                  await _secureStorage
                      .saveAccessToken(refreshResponse['accessToken']);
                  if (refreshResponse['refreshToken'] != null) {
                    await _secureStorage
                        .saveRefreshToken(refreshResponse['refreshToken']);
                  }
                  final opts = Options(
                    method: error.requestOptions.method,
                    headers: {
                      ...error.requestOptions.headers,
                      'Authorization':
                          'Bearer ${refreshResponse['accessToken']}',
                    },
                  );
                  final response = await _dio.request(
                    error.requestOptions.path,
                    options: opts,
                    data: error.requestOptions.data,
                    queryParameters: error.requestOptions.queryParameters,
                  );
                  return handler.resolve(response);
                }
              }
            } catch (e) {
              _logger.error('❌ Token refresh failed: $e');
              await _secureStorage.clearAllTokens();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ================== API Methods ==================

  Future<ApiBalance> getBalance() async {
    final response = await _dio.get(
      'https://balance-service-zug9v.ondigitalocean.app/api/v1/wallet',
    );
    return ApiBalance.fromApi(response.data);
  }

  Future<ApiTransaction> getTransactions() async {
    final response = await _dio.get(
      'https://trx-service-lc9l6.ondigitalocean.app/transactions/all',
    );
    return ApiTransaction.fromApi(response.data);
  }

  Future<ApiAuthInitiate> initiateAuth(String phone, String countryCode) async {
    String cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final response = await _dio.post(
      'https://auth-service-9jf3q.ondigitalocean.app/auth/initiate',
      data: {
        'phone': '+$cleanedPhone',
        'country': countryCode,
      },
    );
    return ApiAuthInitiate.fromApi(response.data);
  }

  Future<ApiAuthVerify> verifyAuth(
      String code, String phone, String userId) async {
    String cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final response = await _dio.post(
      'https://auth-service-9jf3q.ondigitalocean.app/auth/verify',
      data: {
        'phone': '+$cleanedPhone',
        'code': code,
        'userId': userId,
      },
    );
    return ApiAuthVerify.fromApi(response.data);
  }

  Future<ApiAuthRefresh> refreshAuth(String refreshToken) async {
    final response = await _dio.post(
      'https://auth-service-9jf3q.ondigitalocean.app/auth/refresh',
      data: {
        'refreshToken': refreshToken,
      },
    );
    return ApiAuthRefresh.fromApi(response.data);
  }

  Future<ApiVerifyToken> verifyToken(String token) async {
    final response = await _dio.post(
      'https://auth-service-9jf3q.ondigitalocean.app/auth/validate-token',
      data: {
        'token': token,
      },
    );
    return ApiVerifyToken.fromApi(response.data);
  }

  Future<ApiTopUp> getProviders() async {
    final response = await _dio.get(
      'https://trx-service-lc9l6.ondigitalocean.app/providers/all',
    );
    return ApiTopUp.fromApi(response.data);
  }

  Future<ApiTopUpInitiate> initiateTopUp(Map<String, dynamic> data) async {
    final response = await _dio.post(
      'https://trx-service-lc9l6.ondigitalocean.app/transactions/initiate-deposit',
      data: {
        "provider": data['provider'],
        "currency": "CLP",
        "amount": data['amount'],
        "userData": data
      },
    );
    return ApiTopUpInitiate.fromApi(response.data);
  }

  Future<ApiWithdraw> getWithdrawalProviders() async {
    final response = await _dio.get(
      'https://trx-service-lc9l6.ondigitalocean.app/providers/all',
    );
    return ApiWithdraw.fromApi(response.data);
  }

  Future<ApiWithdrawalInitiate> initiateWithdrawal(
      Map<String, dynamic> data) async {
    final response = await _dio.post(
      'https://trx-service-lc9l6.ondigitalocean.app/transactions/initiate-deposit',
      data: {
        "provider": data['provider'],
        "currency": "CLP",
        "amount": data['amount'],
        "userData": data
      },
    );
    return ApiWithdrawalInitiate.fromApi(response.data);
  }

  Future<ApiTransferInitiate> initiateTransfer(
      Map<String, dynamic> data) async {
    final response = await _dio.post(
      'https://transfer-service-dibxk.ondigitalocean.app/api/v1/transfer',
      data: {
        "recipient": data['recipient'],
        "currency": "CLP",
        "amount": data['amount'],
      },
    );
    return ApiTransferInitiate.fromApi(response.data);
  }

  Future<List<ContactModel>> getContacts() async {
    final response = await _dio.get(
      'https://contact-service-w42s8.ondigitalocean.app/api/v1/contacts',
    );
    return (response.data['contacts'] as List)
        .map((json) => ContactModel.fromJson(json))
        .toList();
  }

  Future<String?> addContact(String phone, String? nickname) async {
    final response = await _dio.post(
      'https://contact-service-w42s8.ondigitalocean.app/api/v1/contacts',
      data: {
        'phone': phone,
        'nickname': nickname,
      },
    );
    return response.data['message'];
  }

  Future<ContactModel> updateContact(String phone, String? nickname) async {
    final response = await _dio.patch(
      'https://contact-service-w42s8.ondigitalocean.app/api/v1/contacts/$phone',
      data: {
        'nickname': nickname,
      },
    );
    return ContactModel.fromJson(response.data);
  }

  Future<void> deleteContact(String phone) async {
    await _dio.delete(
      'https://contact-service-w42s8.ondigitalocean.app/api/v1/contacts/$phone',
    );
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<Map<String, dynamic>> checkQrCode(String hash) async {
    final response = await _dio.get(
      'https://merchant-service-gp4xz.ondigitalocean.app/api/v1/qr_code/check/$hash',
    );
    return response.data;
  }

  Future<Map<String, dynamic>> processPayment(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        'https://merchant-service-gp4xz.ondigitalocean.app/api/v1/payment',
        data: data,
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to process payment: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CountryModel>> getCountries() async {
    try {
      final response = await _dio
          .get('https://auth-service-9jf3q.ondigitalocean.app/auth/countries');
      if (response.statusCode == 200) {
        final List<dynamic> countriesJson = response.data['countries'];
        return countriesJson
            .map((json) => CountryModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load countries');
      }
    } catch (e) {
      throw Exception('Failed to load countries: $e');
    }
  }

  Future<List<ContactModel>> getRecentContacts() async {
    final response = await _dio.get(
      'https://contact-service-w42s8.ondigitalocean.app/api/v1/contacts/recent',
    );
    return (response.data['contacts'] as List)
        .map((json) => ContactModel.fromJson(json))
        .toList();
  }

  Future<Map<String, dynamic>> getInitialData({
    int limit = 15,
    int topLimit = 5,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        'https://offer-service-xn3b9.ondigitalocean.app/api/v1/initial-data',
        queryParameters: {
          'limit': limit,
          'top_limit': topLimit,
          'page': page,
        },
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load initial data >.<');
      }
    } catch (e) {
      throw Exception('Error fetching initial data: $e');
    }
  }

  Future<List<Activation>> getActivations(int limit) async {
    final response = await _dio.get(
      'https://offer-service-xn3b9.ondigitalocean.app/api/v1/activations',
      queryParameters: {'limit': limit},
    );
    return (response.data['activations'] as List)
        .map((json) => Activation.fromJson(json))
        .toList();
  }

  Future<ApiCategoriesResponse> getFavoriteCategories({int limit = 100}) async {
    final response = await _dio.get(
      'https://offer-service-xn3b9.ondigitalocean.app/api/v1/favorites/categories',
      queryParameters: {'limit': limit},
    );
    return ApiCategoriesResponse.fromJson(response.data);
  }

  Future<ApiCategoriesResponse> addFavoriteCategory(int categoryId) async {
    final response = await _dio.post(
      'https://offer-service-xn3b9.ondigitalocean.app/api/v1/favorites/categories',
      data: {'category_id': categoryId},
    );
    return ApiCategoriesResponse.fromJson(response.data);
  }

  Future<ApiCategoriesResponse> deleteFavoriteCategory(int categoryId) async {
    final response = await _dio.delete(
      'https://offer-service-xn3b9.ondigitalocean.app/api/v1/favorites/categories/$categoryId',
    );
    return ApiCategoriesResponse.fromJson(response.data);
  }

  Future<ActivationsResponse> getAllActivations() async {
    final response = await _dio.get(
      'https://offer-service-xn3b9.ondigitalocean.app/api/v1/merchants/activations/all',
    );
    return ActivationsResponse.fromJson(response.data);
  }

  Future<ActivationResponse> getActivationByUserAndOffer(
      String userId, int offerId) async {
    final response = await _dio.get(
      'https://offer-service-xn3b9.ondigitalocean.app/api/v1/merchants/activations/$userId/$offerId',
    );
    return ActivationResponse.fromJson(response.data);
  }

  Future<ActivationResponse> checkActivationByUserAndMerchant(
      String userId, String merchantId) async {
    final response = await _dio.get(
      'https://offer-service-xn3b9.ondigitalocean.app/api/v1/merchants/activations/$userId/$merchantId/check',
    );
    return ActivationResponse.fromJson(response.data);
  }

  Future<ActivationResponse> checkActivationById(String activationId) async {
    final response = await _dio.get(
      'https://offer-service-xn3b9.ondigitalocean.app/api/v1/merchants/activations/$activationId/check',
    );
    return ActivationResponse.fromJson(response.data);
  }

  Future<void> completeActivation(String activationId) async {
    await _dio.post(
      'https://offer-service-xn3b9.ondigitalocean.app/api/v1/merchants/activations/$activationId/complete',
    );
  }

  Future<Activation> activateOffer(int offerId) async {
    final response = await _dio.post(
      'https://offer-service-xn3b9.ondigitalocean.app/api/v1/activations/$offerId',
    );
    return Activation.fromJson(response.data['activation']);
  }

  Future<ApiGlobalSearchResponse> searchGlobal(String query,
      {int limit = 5}) async {
    final response = await _dio.get(
      'https://search-service-52g7l.ondigitalocean.app/api/v1/search/global',
      queryParameters: {
        'search': query,
        'limit': limit,
      },
    );
    return ApiGlobalSearchResponse.fromApi(response.data);
  }

  Future<Map<String, dynamic>> getBanners() async {
    final response = await _dio.get(
      'https://offer-service-xn3b9.ondigitalocean.app/api/v1/banners',
    );
    return response.data;
  }

  Future<bool> testApiConnectivity() async {
    _logger.kawaii('✨ Testing API connectivity UwU ✨');
    try {
      // First make sure we have a valid API key
      final apiKeyManager = SecureApiKeyManager();
      final apiKey =
          await apiKeyManager.getApiKey(SecureApiKeyManager.kMainApiKey);
      if (apiKey == null || apiKey == 'dev_api_key_placeholder') {
        _logger.error('❌ Invalid API key detected in connectivity test');
        // Force re-initialization
        await apiKeyManager.removeApiKey(SecureApiKeyManager.kMainApiKey);
        await apiKeyManager.initialize();
      }

      // Perform a simple request to check connectivity
      final response = await _dio.get(
        'https://balance-service-zug9v.ondigitalocean.app/health',
        options: Options(
          validateStatus: (status) =>
              true, // Accept any status code for testing
        ),
      );

      final isConnected =
          response.statusCode != null && response.statusCode! < 500;
      _logger.info(
          '📡 API Connection test: ${isConnected ? "Success" : "Failed"} (${response.statusCode})');

      if (!isConnected) {
        _logger.error('❌ API Connectivity test failed: ${response.statusCode}');
        _logger.error('Response data: ${response.data}');
      }

      return isConnected;
    } catch (e) {
      _logger.error('❌ API Connectivity test error: $e');
      return false;
    }
  }
}
