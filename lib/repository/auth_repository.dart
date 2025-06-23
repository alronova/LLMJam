// import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  final _storage = FlutterSecureStorage();

  final String baseUrl = dotenv.get("B_URL");

  Future<void> saveUser(Object user) async {
    await _storage.write(key: 'auth_user', value: jsonEncode(user));
  }

  Future<void> deleteUserCreds() async {
    await _storage.delete(key: 'auth_user');
    await _storage.delete(key: 'auth_token');
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final token = await getToken();
    if (token != null && !JwtDecoder.isExpired(token)) {
      final decodedToken = JwtDecoder.decode(token);
      final userData = await _storage.read(key: 'auth_user');
      // debugPrint('Decoded Token: $decodedToken\nUser Data: $userData');
      if (userData != null) {
        final decodedUserData = jsonDecode(userData);
        if (decodedUserData['id'] == decodedToken['user_id']) {
          return decodedUserData;
        } else {
          await deleteUserCreds();
          throw Exception(
            'User ID mismatch, please log in again.',
          );
        }
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      await saveToken(body['token']);
      await saveUser(body['user']);
      return JwtDecoder.decode(body['token']);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message']);
    }
  }

  Future<Map<String, dynamic>> signup(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      await saveToken(body['token']);
      await saveUser(body['user']);
      return JwtDecoder.decode(body['token']);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message']);
    }
  }
}
