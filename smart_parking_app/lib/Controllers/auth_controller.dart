import '../models/user.dart';

class AuthController {
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> register(User user, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> verifyCode(String code) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}