abstract class SessionState {}

class InitialLoading extends SessionState {}

class Authenticated extends SessionState {
  final String accessToken;
  Authenticated(this.accessToken);
}

class Unauthenticated extends SessionState {}

class RefreshingTokens extends SessionState {}
