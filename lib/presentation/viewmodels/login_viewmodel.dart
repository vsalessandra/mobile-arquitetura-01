import 'package:flutter/foundation.dart';
import '../../core/network/session_manager.dart';
import '../../domain/repositories/auth_repository.dart';

class LoginState {
  const LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    bool clearError = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class LoginViewModel {
  LoginViewModel(this._authRepository, this._sessionManager);

  final AuthRepository _authRepository;
  final SessionManager _sessionManager;

  final ValueNotifier<LoginState> state = ValueNotifier(const LoginState());

  Future<bool> login(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      state.value = state.value.copyWith(
        errorMessage: 'Usuário e senha não podem ser vazios.',
      );
      return false;
    }

    state.value = state.value.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _authRepository.login(username.trim(), password.trim());
      _sessionManager.login(user);
      state.value = state.value.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (error) {
      state.value = state.value.copyWith(
        isLoading: false,
        errorMessage: error.toString().replaceFirst('Failure: ', '').replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  void clearError() {
    state.value = state.value.copyWith(clearError: true);
  }

  void dispose() {
    state.dispose();
  }
}
