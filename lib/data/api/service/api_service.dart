import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/data/api/api_auth_initiate.dart';
import 'package:zippy/data/api/api_auth_refresh.dart';
import 'package:zippy/data/api/api_auth_verify.dart';
import 'package:zippy/data/api/api_balance.dart';
import 'package:zippy/data/api/api_top_up.dart';
import 'package:zippy/data/api/api_top_up_initiate.dart';
import 'package:zippy/data/api/api_transaction.dart';
import 'package:zippy/data/api/api_verify_token.dart';
import 'package:zippy/data/api/api_withdraw.dart';
import 'package:zippy/data/api/api_withdrawal_initiate.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    _addTokenInterceptor();
  }

  Future<ApiBalance> getBalance() async {
    final response = await _dio.get(
      'https://balance-service-app-sz8if.ondigitalocean.app/api/v1/wallet',
    );
    return ApiBalance.fromApi(response.data);
  }

  Future<ApiTransaction> getTransactions() async {
    final response = await _dio.get(
      'https://lionfish-app-9ixm6.ondigitalocean.app/transactions/all',
    );
    return ApiTransaction.fromApi(response.data);
  }

  Future<ApiAuthInitiate> initiateAuth(String phone) async {
    String cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final response = await _dio.post(
      'https://auth-service-app-m9z4y.ondigitalocean.app/auth/initiate',
      data: {
        'phone': '+$cleanedPhone',
        'currency': 'CLP',
      },
    );
    return ApiAuthInitiate.fromApi(response.data);
  }

  Future<ApiAuthVerify> verifyAuth(
      String code, String phone, String userId) async {
    String cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    final response = await _dio.post(
      'https://auth-service-app-m9z4y.ondigitalocean.app/auth/verify',
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
      'https://auth-service-app-m9z4y.ondigitalocean.app/auth/refresh',
      data: {
        'refreshToken': refreshToken,
      },
    );
    return ApiAuthRefresh.fromApi(response.data);
  }

  Future<ApiVerifyToken> verifyToken(String token) async {
    final response = await _dio.post(
      'https://auth-service-app-m9z4y.ondigitalocean.app/auth/validate-token',
      data: {
        'token': token,
      },
    );
    return ApiVerifyToken.fromApi(response.data);
  }

  Future<String?> _getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('accessToken');
    return token;
  }

  Future<ApiTopUp> getProviders() async {
    final response = await _dio.get(
      'https://lionfish-app-9ixm6.ondigitalocean.app/providers/all',
    );
    return ApiTopUp.fromApi(response.data);
  }

  Future<ApiTopUpInitiate> initiateTopUp(Map<String, dynamic> data) async {
    final response = await _dio.post(
      'https://lionfish-app-9ixm6.ondigitalocean.app/transactions/initiate-payment',
      data: {
        "provider": "zippyBankCard",
        "currency": "CLP",
        "amount": 3,
        "userData": {
          "email": "user20@example.com",
          "documentId": "111111111",
        }
      },
    );
    return ApiTopUpInitiate.fromApi(response.data);
  }

  Future<ApiWithdraw> getWithdrawalProviders() async {
    final response = await _dio.get(
      'https://lionfish-app-9ixm6.ondigitalocean.app/providers/all',
    );
    return ApiWithdraw.fromApi(response.data);
  }

  Future<ApiWithdrawalInitiate> initiateWithdrawal(
      Map<String, dynamic> data) async {
    final response = await _dio.post(
      'https://lionfish-app-9ixm6.ondigitalocean.app/transactions/initiate-payout',
      data: {
        "provider": "zippyBankCard",
        "currency": "CLP",
        "amount": 3,
        "userData": {
          "email": "user20@example.com",
          "documentId": "111111111",
        }
      },
    );
    return ApiWithdrawalInitiate.fromApi(response.data);
  }

  void _addTokenInterceptor() {
    _dio.interceptors.add(InterceptorsWrapper(onRequest:
        (RequestOptions options, RequestInterceptorHandler handler) async {
      String? accessToken = await _getAccessToken();

      if (accessToken != null) {
        options.headers['Authorization'] =
            'Bearer $accessToken'; // Use 'Bearer' if needed
      }

      options.headers['x-api-key'] =
          'BKC4X9KXCrsCpVZB7DvN4rkhrHZSu6sD'; // Add x-api-key header

      return handler.next(options);
    }));
  }
}
