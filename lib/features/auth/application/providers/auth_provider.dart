import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../domain/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? error;

  AuthState({this.isLoading = false, this.user, this.error});

  AuthState copyWith({bool? isLoading, UserModel? user, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _checkToken();
    return AuthState();
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> _checkToken() async {
    final token = await _repository.getToken();
    if (token != null) {
      final user = await _repository.getMe();
      if (user != null) {
        state = state.copyWith(user: user);
      }
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.login(email, password);
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      final msg = _parseError(e);
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    }
  }

  Future<bool> register(String name, String email, String phone, String password, String role) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.register(name, email, phone, password, role);
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      final msg = _parseError(e);
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    }
  }

  String _parseError(Object e) {
    if (e is DioException) {
      return e.response?.data?['error']?['message'] as String? ??
          e.message ??
          'Something went wrong';
    }
    return e.toString();
  }

  Future<void> logout() async {
    await _repository.logout();
    state = AuthState(); // Reset everything
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
