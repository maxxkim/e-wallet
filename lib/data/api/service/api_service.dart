import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:zippy/data/api/api_auth_initiate.dart';
import 'package:zippy/data/api/api_auth_refresh.dart';
import 'package:zippy/data/api/api_auth_verify.dart';
import 'package:zippy/data/api/api_balance.dart';
import 'package:zippy/data/api/api_category_responce.dart';
import 'package:zippy/data/api/api_global_search_response.dart';
import 'package:zippy/data/api/api_top_up.dart';
import 'package:zippy/data/api/api_top_up_initiate.dart';
import 'package:zippy/data/api/api_transaction.dart';
import 'package:zippy/data/api/api_transfer_initiate.dart';
import 'package:zippy/data/api/api_verify_token.dart';
import 'package:zippy/data/api/api_withdraw.dart';
import 'package:zippy/data/api/api_withdrawal_initiate.dart';
import 'package:zippy/data/api/responcses/activation_responses.dart';
import 'package:zippy/domain/model/auth/country_model.dart';
import 'package:zippy/domain/model/contacts/contact_model.dart';
import 'package:zippy/domain/model/offer/activation_model.dart';
import 'package:zippy/internal/services/secure_storage_service.dart';

class ApiService {
  final Dio _dio = Dio();
  final SecureStorageService _secureStorage = SecureStorageService();

  ApiService() {
    _configureInterceptors();
  }

  void _configureInterceptors() {
    _dio.interceptors.clear();

    // Add request interceptor
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
          // Add API key to all requests
          options.headers['x-api-key'] = 'TV99UCUiCfmayqRqPVXnTxPpmuqKxrT3';

          // Add authorization header if token exists
          String? accessToken = await _secureStorage.getAccessToken();
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }

          return handler.next(options);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          // Handle 401 Unauthorized errors
          if (error.response?.statusCode == 401) {
            // Try to refresh the token
            try {
              String? refreshToken = await _secureStorage.getRefreshToken();
              if (refreshToken != null) {
                final response = await _dio.post(
                  'https://api.zentro.io/v1/auth/refresh',
                  data: {
                    'refreshToken': refreshToken,
                  },
                );

                final ApiAuthRefresh refreshResponse =
                    ApiAuthRefresh.fromApi(response.data);

                if (refreshResponse.accessToken != null) {
                  await _secureStorage
                      .saveAccessToken(refreshResponse.accessToken!);
                  if (refreshResponse.refreshToken != null) {
                    await _secureStorage
                        .saveRefreshToken(refreshResponse.refreshToken!);
                  }

                  // Retry the original request with new token
                  final opts = Options(
                    method: error.requestOptions.method,
                    headers: {
                      ...error.requestOptions.headers,
                      'Authorization': 'Bearer ${refreshResponse.accessToken}',
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
              // If token refresh fails, clear tokens and let the error continue
              await _secureStorage.clearAllTokens();
            }
          }

          return handler.next(error);
        },
      ),
    );

    /*// Add logging interceptor in debug mode
    assert(() {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
      return true;
    }());*/
  }

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
        'https://contact-service-w42s8.ondigitalocean.app/api/v1/contacts');
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
        'https://contact-service-w42s8.ondigitalocean.app/api/v1/contacts/$phone');
  }

  Future<Map<String, dynamic>> checkQrCode(String hash) async {
    final response = await _dio.get(
      'https://merchant-service-gp4xz.ondigitalocean.app/api/v1/qr_code/check/$hash',
    );
    return response.data;
  }

  Future<Map<String, dynamic>> processPayment(Map<String, dynamic> data) async {
    try {
      // Log what we're sending for debugging purposes

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
        'https://contact-service-w42s8.ondigitalocean.app/api/v1/contacts/recent');
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
        'https://offer-service-xn3b9.ondigitalocean.app/api/v1/merchants/activations/all');
    return ActivationsResponse.fromJson(response.data);
  }

  Future<ActivationResponse> getActivationByUserAndOffer(
      String userId, int offerId) async {
    final response = await _dio.get(
        'https://offer-service-xn3b9.ondigitalocean.app/api/v1/merchants/activations/$userId/$offerId');
    return ActivationResponse.fromJson(response.data);
  }

  Future<ActivationResponse> checkActivationByUserAndMerchant(
      String userId, String merchantId) async {
    final response = await _dio.get(
        'https://offer-service-xn3b9.ondigitalocean.app/api/v1/merchants/activations/$userId/$merchantId/check');
    return ActivationResponse.fromJson(response.data);
  }

  Future<ActivationResponse> checkActivationById(String activationId) async {
    final response = await _dio.get(
        'https://offer-service-xn3b9.ondigitalocean.app/api/v1/merchants/activations/$activationId/check');
    return ActivationResponse.fromJson(response.data);
  }

  Future<void> completeActivation(String activationId) async {
    await _dio.post(
        'https://offer-service-xn3b9.ondigitalocean.app/api/v1/merchants/activations/$activationId/complete');
  }

  Future<Activation> activateOffer(int offerId) async {
    final response = await _dio.post(
        'https://offer-service-xn3b9.ondigitalocean.app/api/v1/activations/$offerId');
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

  void _addTokenInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers['x-api-key'] = 'TV99UCUiCfmayqRqPVXnTxPpmuqKxrT3';
          String? accessToken = await _getAccessToken();
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<String?> _getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }
}
