import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(dioProvider),
    ref.watch(secureStorageProvider),
  );
});

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<UserModel> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    if (email.contains('@')) {
      await _storage.write(key: 'jwt_token', value: 'fake_jwt_token_123');
      return UserModel(id: '1', name: 'Test User', email: email, role: 'Renter');
    }
    throw Exception('Invalid credentials');
  }

  Future<UserModel> register(String name, String email, String phone, String password, String role) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    await _storage.write(key: 'jwt_token', value: 'fake_jwt_token_123');
    return UserModel(id: '1', name: name, email: email, role: role, phone: phone);
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }
}
