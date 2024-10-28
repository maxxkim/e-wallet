import 'package:zippy/domain/model/auth/auth_inititate_model.dart';
import 'package:zippy/domain/model/auth/auth_verify_model.dart';

abstract class AuthRepository {
  Future<AuthInitiate> initiateAuth();
  Future<AuthVerify> verifyAuth();
}