import 'package:dio/dio.dart';
import 'package:zippy/data/api/api_auth_initiate.dart';
import 'package:zippy/data/api/api_auth_verify.dart';
import 'package:zippy/data/api/api_balance.dart';
import 'package:zippy/data/api/api_top_up.dart';
import 'package:zippy/data/api/api_transaction.dart';
import 'package:zippy/data/api/api_withdraw.dart';
import 'package:zippy/data/api/request/get_top_up_body.dart';
import 'package:zippy/data/api/request/get_withdraw_body.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    // Добавление интерсептора для установки токена в заголовки
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] =
            'Bearer fake-user'; // Установка токена
        return handler.next(options);
      },
    ));
  }

  Future<ApiTopUp> getTopUp(GetTopUpBody body) async {
    final response = await _dio.post(
      'https://payin-75jkb5hnza-uc.a.run.app/',
      queryParameters: body.toApi(),
    );
    return ApiTopUp.fromApi(response.data);
  }

  Future<ApiWithdraw> getWithdraw(GetWithdrawBody body) async {
    final response = await _dio.post(
      'https://payin-75jkb5hnza-uc.a.run.app/',
      queryParameters: body.toApi(),
    );
    return ApiWithdraw.fromApi(response.data);
  }

  Future<ApiBalance> getBalance() async {
    final response = await _dio.get(
      'https://d2ef-51-159-97-191.ngrok-free.app/wallet/user122/balance',
    );
    return ApiBalance.fromApi(response.data);
  }

  Future<ApiTransaction> getTransactions() async {
    final response = await _dio.get(
      'https://d2ef-51-159-97-191.ngrok-free.app/transactions/all',
    );
    return ApiTransaction.fromApi(response.data);
  }

  Future<ApiAuthInitiate> initiateAuth() async {
    final response = await _dio.post(
      'https://d2ef-51-159-97-191.ngrok-free.app/transactions/all',
    );
    return ApiAuthInitiate.fromApi(response.data);
  }

  Future<ApiAuthVerify> verifyAuth() async {
    final response = await _dio.post(
      'https://d2ef-51-159-97-191.ngrok-free.app/transactions/all',
    );
    return ApiAuthVerify.fromApi(response.data);
  }
}
