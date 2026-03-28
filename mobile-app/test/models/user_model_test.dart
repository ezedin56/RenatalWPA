import 'package:flutter_test/flutter_test.dart';
import '../../lib/features/auth/domain/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('fromJson creates a valid UserModel instance', () {
      final Map<String, dynamic> json = {
        'id': '123',
        'name': 'John Doe',
        'email': 'john@example.com',
        'role': 'Renter',
        'phone': '1234567890',
        'avatarUrl': 'https://example.com/avatar.jpg',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '123');
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.role, 'Renter');
      expect(user.phone, '1234567890');
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('toJson returns a valid map', () {
      final user = UserModel(
        id: '456',
        name: 'Jane Smith',
        email: 'jane@example.com',
        role: 'Owner',
      );

      final json = user.toJson();

      expect(json['id'], '456');
      expect(json['name'], 'Jane Smith');
      expect(json['email'], 'jane@example.com');
      expect(json['role'], 'Owner');
      expect(json['phone'], null);
      expect(json['avatarUrl'], null);
    });
  });
}
