import 'package:equatable/equatable.dart';
import '../../../core/state/view_state.dart';

class VerificationState extends Equatable {
  final Status status;
  final bool isVerified;
  final String? errorMessage;
  final String? successMessage;
  final int resendCooldownSeconds;
  final String email;
  final bool isTokenVerification;

  const VerificationState({
    this.status = Status.idle,
    this.isVerified = false,
    this.errorMessage,
    this.successMessage,
    this.resendCooldownSeconds = 0,
    this.email = '',
    this.isTokenVerification = false,
  });

  bool get isLoading => status == Status.loading;
  bool get canResend => resendCooldownSeconds == 0;

  VerificationState copyWith({
    Status? status,
    bool? isVerified,
    String? errorMessage,
    String? successMessage,
    int? resendCooldownSeconds,
    String? email,
    bool? isTokenVerification,
  }) {
    return VerificationState(
      status: status ?? this.status,
      isVerified: isVerified ?? this.isVerified,
      errorMessage: errorMessage,
      successMessage: successMessage,
      resendCooldownSeconds: resendCooldownSeconds ?? this.resendCooldownSeconds,
      email: email ?? this.email,
      isTokenVerification: isTokenVerification ?? this.isTokenVerification,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isVerified,
        errorMessage,
        successMessage,
        resendCooldownSeconds,
        email,
        isTokenVerification,
      ];
}
