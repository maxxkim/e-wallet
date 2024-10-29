import 'package:zippy/data/api/api_auth_verify.dart';
import 'package:zippy/domain/model/auth/auth_verify_model.dart';

class AuthVerifyMapper {
  static AuthVerify fromApi(ApiAuthVerify apiAuthVerify) {
    return AuthVerify(
      isVerified: apiAuthVerify.isVerified,
      accessToken: apiAuthVerify.accessToken,
      refreshToken: apiAuthVerify.refreshToken,
    );
  }
}
