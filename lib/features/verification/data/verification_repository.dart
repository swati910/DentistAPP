import '../../../core/errors/app_exception.dart';

abstract class VerificationRepository {
  Future<bool> checkEmailLinkStatus({required String email});
  Future<void> verifyOtp({required String email, required String otp});
  Future<void> verifyEmailToken({required String token});
  Future<void> resendVerificationEmail({required String email});
  Future<void> resendVerificationOtp({required String email});
  Future<void> updateVerificationEmail({required String oldEmail, required String newEmail});
}

class MockVerificationRepository implements VerificationRepository {
  final Map<String, int> _resendAttempts = {};

  @override
  Future<bool> checkEmailLinkStatus({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (email.contains('unverified@')) {
      return false;
    }
    return true;
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (otp == '000000') {
      throw const ExpiredTokenException('This verification code has expired. Please request a new one.');
    }
    if (otp == '888888') {
      throw const TokenAlreadyUsedException('This verification code has already been used. Please request a new code.');
    }
    if (otp == '777777') {
      throw const RateLimitException('Too many verification attempts. Please wait 15 minutes before trying again.');
    }
    if (otp != '123456') {
      throw const InvalidTokenException('Incorrect verification code. Hint: Use 123456 for demo.');
    }
  }

  @override
  Future<void> verifyEmailToken({required String token}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (token == 'expired-token') {
      throw const ExpiredTokenException('This verification link has expired. Please request a new verification email.');
    }
    if (token == 'used-token') {
      throw const TokenAlreadyUsedException('This verification link has already been used. Please log in.');
    }
    if (token.isEmpty || token == 'invalid-token') {
      throw const InvalidTokenException('The verification link is invalid or malformed.');
    }
  }

  @override
  Future<void> resendVerificationEmail({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _resendAttempts[email] = (_resendAttempts[email] ?? 0) + 1;
    if ((_resendAttempts[email] ?? 0) > 5) {
      throw const RateLimitException('Too many resend attempts. Please wait a few minutes before trying again.');
    }
  }

  @override
  Future<void> resendVerificationOtp({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _resendAttempts[email] = (_resendAttempts[email] ?? 0) + 1;
    if ((_resendAttempts[email] ?? 0) > 5) {
      throw const RateLimitException('Too many resend attempts. Please wait a few minutes before trying again.');
    }
  }

  @override
  Future<void> updateVerificationEmail({required String oldEmail, required String newEmail}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!newEmail.contains('@') || !newEmail.contains('.')) {
      throw const ValidationException('Please enter a valid email address.');
    }
  }
}
