/// Lets Dio interceptors notify auth state when the session is invalid (401).
class AuthSessionBridge {
  AuthSessionBridge._();
  static final AuthSessionBridge instance = AuthSessionBridge._();

  Future<void> Function()? onSessionExpired;

  void notifySessionExpired() {
    onSessionExpired?.call();
  }
}
