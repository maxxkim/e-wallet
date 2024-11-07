import 'package:zippy/data/api/api_verify_token.dart';

class TokenVerificationMapper {
  static bool fromApi(ApiVerifyToken apiVerifyToken) {
    return apiVerifyToken.valid;
  }
}
