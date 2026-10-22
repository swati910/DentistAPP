import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/state/view_state.dart';
import '../data/verification_repository.dart';
import 'verification_event.dart';
import 'verification_state.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final VerificationRepository _repository;
  Timer? _cooldownTimer;

  VerificationBloc({required VerificationRepository repository})
      : _repository = repository,
        super(const VerificationState()) {
    on<CheckEmailVerificationStatus>(_onCheckEmailVerificationStatus);
    on<VerifyOtpSubmitted>(_onVerifyOtpSubmitted);
    on<VerifyEmailTokenSubmitted>(_onVerifyEmailTokenSubmitted);
    on<ResendVerificationEmailRequested>(_onResendVerificationEmailRequested);
    on<ResendVerificationOtpRequested>(_onResendVerificationOtpRequested);
    on<UpdateVerificationEmailRequested>(_onUpdateVerificationEmailRequested);
    on<VerificationCooldownTicked>(_onVerificationCooldownTicked);
    on<ResetVerificationFlow>(_onResetVerificationFlow);
  }

  Future<void> _onCheckEmailVerificationStatus(
    CheckEmailVerificationStatus event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      final verified = await _repository.checkEmailLinkStatus(email: event.email);
      if (verified) {
        emit(state.copyWith(
          status: Status.success,
          isVerified: true,
          email: event.email,
          successMessage: 'Email successfully verified!',
        ));
      } else {
        emit(state.copyWith(
          status: Status.idle,
          isVerified: false,
          email: event.email,
          errorMessage: 'Email is not yet verified. Please click the link sent to your inbox.',
        ));
      }
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: 'Unable to check verification status. Please try again.',
      ));
    }
  }

  Future<void> _onVerifyOtpSubmitted(
    VerifyOtpSubmitted event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      await _repository.verifyOtp(email: event.email, otp: event.otp);
      emit(state.copyWith(
        status: Status.success,
        isVerified: true,
        email: event.email,
        successMessage: 'Account verified successfully!',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: 'Invalid code. Please try again.',
      ));
    }
  }

  Future<void> _onVerifyEmailTokenSubmitted(
    VerifyEmailTokenSubmitted event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null, isTokenVerification: true));

    try {
      await _repository.verifyEmailToken(token: event.token);
      emit(state.copyWith(
        status: Status.success,
        isVerified: true,
        isTokenVerification: false,
        successMessage: 'Email verified successfully via activation link!',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.message,
        isTokenVerification: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: 'Unable to verify email link. Please try entering the OTP instead.',
        isTokenVerification: false,
      ));
    }
  }

  Future<void> _onResendVerificationEmailRequested(
    ResendVerificationEmailRequested event,
    Emitter<VerificationState> emit,
  ) async {
    if (!state.canResend) return;

    emit(state.copyWith(status: Status.loading, errorMessage: null));
    try {
      await _repository.resendVerificationEmail(email: event.email);
      _startCooldown();
      emit(state.copyWith(
        status: Status.idle,
        email: event.email,
        resendCooldownSeconds: AppConstants.otpCooldownSeconds,
        successMessage: 'A new verification link has been sent to your email.',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: 'Failed to resend email. Please try again.',
      ));
    }
  }

  Future<void> _onResendVerificationOtpRequested(
    ResendVerificationOtpRequested event,
    Emitter<VerificationState> emit,
  ) async {
    if (!state.canResend) return;

    emit(state.copyWith(status: Status.loading, errorMessage: null));
    try {
      await _repository.resendVerificationOtp(email: event.email);
      _startCooldown();
      emit(state.copyWith(
        status: Status.idle,
        email: event.email,
        resendCooldownSeconds: AppConstants.otpCooldownSeconds,
        successMessage: 'A fresh 6-digit OTP code has been dispatched.',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: 'Failed to resend code. Please try again.',
      ));
    }
  }

  Future<void> _onUpdateVerificationEmailRequested(
    UpdateVerificationEmailRequested event,
    Emitter<VerificationState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      await _repository.updateVerificationEmail(
        oldEmail: event.oldEmail,
        newEmail: event.newEmail,
      );
      _startCooldown();
      emit(state.copyWith(
        status: Status.idle,
        email: event.newEmail,
        resendCooldownSeconds: AppConstants.otpCooldownSeconds,
        successMessage: 'Verification email updated. A fresh code has been sent.',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: 'Unable to update email address.',
      ));
    }
  }

  void _onVerificationCooldownTicked(
    VerificationCooldownTicked event,
    Emitter<VerificationState> emit,
  ) {
    emit(state.copyWith(resendCooldownSeconds: event.secondsRemaining));
  }

  void _onResetVerificationFlow(
    ResetVerificationFlow event,
    Emitter<VerificationState> emit,
  ) {
    _cooldownTimer?.cancel();
    emit(const VerificationState());
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    int secondsRemaining = AppConstants.otpCooldownSeconds;
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      secondsRemaining--;
      if (secondsRemaining <= 0) {
        timer.cancel();
        add(const VerificationCooldownTicked(0));
      } else {
        add(VerificationCooldownTicked(secondsRemaining));
      }
    });
  }

  @override
  Future<void> close() {
    _cooldownTimer?.cancel();
    return super.close();
  }
}
