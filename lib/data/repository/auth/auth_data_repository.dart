import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/domain/model/auth/auth_inititate_model.dart';
import 'package:zippy/domain/model/auth/auth_refresh_mode.dart';
import 'package:zippy/domain/model/auth/auth_verify_model.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';

class AuthDataRepository extends AuthRepository {
  final ApiUtil _apiUtil;

  AuthDataRepository(this._apiUtil);

  @override
  Future<AuthInitiate> initiateAuth(String phone, String countryCode) {
    return _apiUtil.initiateAuth(phone, countryCode);
  }

  @override
  Future<AuthVerify> verifyAuth(
    String code,
    String phone,
    String userId,
  ) {
    return _apiUtil.verifyAuth(code, phone, userId);
  }

  @override
  Future<AuthRefresh> refreshAuth(String refreshToken) {
    return _apiUtil.refreshAuth(refreshToken);
  }

  @override
  Future<bool> verifyToken(String accessToken) {
    return _apiUtil.verifyToken(accessToken);
  }
}
