import 'package:zippy/domain/model/auth/auth_inititate_model.dart';
import 'package:zippy/domain/model/auth/auth_refresh_mode.dart';
import 'package:zippy/domain/model/auth/auth_verify_model.dart';

abstract class AuthRepository {
  Future<AuthInitiate> initiateAuth(String phone, String countryCode);
  Future<AuthVerify> verifyAuth(String code, String phone, String userId);
  Future<AuthRefresh> refreshAuth(String refreshToken);
  Future<bool> verifyToken(String accessToken);
}
