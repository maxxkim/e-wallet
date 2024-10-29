import 'package:zippy/data/api/api_auth_initiate.dart';
import 'package:zippy/domain/model/auth/auth_inititate_model.dart';

class AuthInitiateMapper {
  static AuthInitiate fromApi(ApiAuthInitiate apiAuthInitiate) {
    return AuthInitiate(
      isNewUser: apiAuthInitiate.isNewUser,
      walletId: apiAuthInitiate.walletId,
      userId: apiAuthInitiate.userId,
    );
  }
}
