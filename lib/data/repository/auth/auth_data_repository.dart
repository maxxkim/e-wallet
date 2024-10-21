
import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';

class AuthDataRepository extends AuthRepository {
  final ApiUtil _apiUtil;

  AuthDataRepository(this._apiUtil);

}