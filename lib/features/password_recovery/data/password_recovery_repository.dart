import '../../../core/errors/app_exception.dart';

abstract class PasswordRecoveryRepository {
  Future<void> requestPasswordReset({required String email});
  Future<String> verifyResetCode({required String email, required String code});
  Future<String> verifyResetToken({required String token});
  Future<void> resendResetCode({required String email});
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  });
}

class MockPasswordRecoveryRepository implements PasswordRecoveryRepository {
  final Map<String, int> _resendAttempts = {};
  final Set<String> _usedTokens = {};

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final trimmed = email.trim().toLowerCase();

    if (trimmed == 'ratelimit@clinic.com') {
      throw const RateLimitException('Too many password reset requests. Please wait 15 minutes.');
    }
    // Note: For privacy and account enumeration security,
    // unknown emails return success so attacker cannot probe existing accounts.
  }

  @override
  Future<String> verifyResetCode({required String email, required String code}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (code == '000000') {
      throw const ExpiredTokenException('This reset code has expired. Please request a new code.');
    }
    if (code == '888888') {
      throw const TokenAlreadyUsedException('This reset code has already been used. Please request a new code.');
    }
    if (code == '777777') {
      throw const RateLimitException('Too many verification attempts. Please wait 15 minutes before trying again.');
    }
    if (code != '123456') {
      throw const InvalidTokenException('The 6-digit code is incorrect. Try 123456 for demo.');
    }
    return 'demo-valid-reset-token-xyz789';
  }

  @override
  Future<String> verifyResetToken({required String token}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (token == 'expired-token') {
      throw const ExpiredTokenException('The reset link has expired. Please request a new password reset.');
    }
    if (_usedTokens.contains(token) || token == 'used-token') {
      throw const TokenAlreadyUsedException('The reset link has already been used. Please request a new link.');
    }
    if (token.isEmpty || token == 'invalid-token') {
      throw const InvalidTokenException('The password reset link is invalid or malformed.');
    }
    return token;
  }

  @override
  Future<void> resendResetCode({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _resendAttempts[email] = (_resendAttempts[email] ?? 0) + 1;
    if ((_resendAttempts[email] ?? 0) > 5) {
      throw const RateLimitException('Too many resend attempts. Please wait a few minutes before trying again.');
    }
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (resetToken.isEmpty || resetToken == 'expired-token') {
      throw const ExpiredTokenException('Reset session has expired. Please start again.');
    }
    if (_usedTokens.contains(resetToken) || resetToken == 'used-token') {
      throw const TokenAlreadyUsedException('This reset session has already been consumed. Please request a new reset.');
    }
    _usedTokens.add(resetToken);
  }
}
