
import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/domain/model/auth/auth_inititate_model.dart';
import 'package:zippy/domain/model/auth/auth_verify_model.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';

class AuthDataRepository extends AuthRepository {
  final ApiUtil _apiUtil;

  AuthDataRepository(this._apiUtil);

  @override
  Future<AuthInitiate> initiateAuth() {
    return _apiUtil.initiateAuth();
  }

  @override
  Future<AuthVerify> verifyAuth() {
  return _apiUtil.verifyAuth();
  }

  
}