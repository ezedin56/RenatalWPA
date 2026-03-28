import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
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
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    final data = response.data['data'];
    final token = data['token'] as String;
    await _storage.write(key: 'jwt_token', value: token);
    return UserModel.fromJson(data['user']);
  }

  Future<UserModel> register(
    String name,
    String email,
    String phone,
    String password,
    String role,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role.toLowerCase(),
      },
    );
    final data = response.data['data'];
    final token = data['token'] as String;
    await _storage.write(key: 'jwt_token', value: token);
    return UserModel.fromJson(data['user']);
  }

  Future<UserModel?> getMe() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return null;
    try {
      final response = await _dio.get(ApiEndpoints.me);
      return UserModel.fromJson(response.data['data']);
    } catch (_) {
      await _storage.delete(key: 'jwt_token');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } catch (_) {
      // Best-effort logout
    } finally {
      await _storage.delete(key: 'jwt_token');
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }
}
