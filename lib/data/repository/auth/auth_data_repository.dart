import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/domain/model/auth/auth_inititate_model.dart';
import 'package:zippy/domain/model/auth/auth_verify_model.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';

class AuthDataRepository extends AuthRepository {
  final ApiUtil _apiUtil;

  AuthDataRepository(this._apiUtil);

  @override
  Future<AuthInitiate> initiateAuth(String phone) {
    return _apiUtil.initiateAuth(phone);
  }

  @override
  Future<AuthVerify> verifyAuth(String code, String phone, String userId) {
    return _apiUtil.verifyAuth(code, phone, userId);
  }
}
