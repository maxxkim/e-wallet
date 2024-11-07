import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/data/api/api_auth_initiate.dart';
import 'package:zippy/data/api/api_auth_refresh.dart';
import 'package:zippy/data/api/api_auth_verify.dart';
import 'package:zippy/data/api/api_auth_verify_token.dart';
import 'package:zippy/data/api/api_balance.dart';
import 'package:zippy/data/api/api_top_up.dart';
import 'package:zippy/data/api/api_transaction.dart';
import 'package:zippy/data/api/api_withdraw.dart';
import 'package:zippy/data/api/request/get_top_up_body.dart';
import 'package:zippy/data/api/request/get_withdraw_body.dart';

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

  Future<ApiAuthVerifyToken> verifyToken(String token) async {
    final response = await _dio.post(
      'https://auth-service-app-m9z4y.ondigitalocean.app/auth/verify',
      data: {
        'token': token,
      },
    );
    return ApiAuthVerifyToken.fromApi(response.data);
  }

  Future<String?> _getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('accessToken');
    return token;
  }

  void _addTokenInterceptor() {
    _dio.interceptors.add(InterceptorsWrapper(onRequest:
        (RequestOptions options, RequestInterceptorHandler handler) async {
      String? accessToken = await _getAccessToken();

      if (accessToken != null) {
        options.headers['Authorization'] =
            'Bearer $accessToken'; // Use 'Bearer' if needed
      }
      print(accessToken);

      return handler.next(options);
    }));
  }
}
