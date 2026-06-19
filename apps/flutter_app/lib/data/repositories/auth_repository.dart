import '../sources/auth_data_source.dart';
import '../../domain/models/user_model.dart';

abstract class AuthRepository {
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
    required String gender,
    required String sexualOrientation,
    required int age,
  });

  Future<User> signIn({
    required String email,
    required String password,
  });

  Future<User> signInWithGoogle({
    required String idToken,
    String? accessToken,
  });

  Future<bool> userRequiresProfileCompletion(String userId);

  Future<void> logout();

  Future<User> getCurrentUser();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
    required String gender,
    required String sexualOrientation,
    required int age,
  }) =>
      dataSource.signUp(
        email: email,
        password: password,
        name: name,
        gender: gender,
        sexualOrientation: sexualOrientation,
        age: age,
      );

  @override
  Future<User> signIn({
    required String email,
    required String password,
  }) =>
      dataSource.signIn(email: email, password: password);

  @override
  Future<User> signInWithGoogle({
    required String idToken,
    String? accessToken,
  }) =>
      dataSource.signInWithGoogle(idToken: idToken, accessToken: accessToken);

  @override
  Future<bool> userRequiresProfileCompletion(String userId) =>
      dataSource.userRequiresProfileCompletion(userId);

  @override
  Future<void> logout() => dataSource.logout();

  @override
  Future<User> getCurrentUser() => dataSource.getCurrentUser();
}
