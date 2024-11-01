import 'package:zippy/data/api/api_auth_refresh.dart';
import 'package:zippy/domain/model/auth/auth_refresh_mode.dart';

class AuthRefreshMapper {
  static AuthRefresh fromApi(ApiAuthRefresh apiAuthRefresh) {
    return AuthRefresh(
      accessToken: apiAuthRefresh.accessToken,
      refreshToken: apiAuthRefresh.refreshToken,
    );
  }
}
