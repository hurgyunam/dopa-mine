abstract class AuthSessionTokenProvider {
  Future<String?> getAccessToken();
}

class InMemoryAuthSessionTokenProvider implements AuthSessionTokenProvider {
  String? _accessToken;

  void updateAccessToken(String? accessToken) {
    _accessToken = accessToken;
  }

  @override
  Future<String?> getAccessToken() async => _accessToken;
}
