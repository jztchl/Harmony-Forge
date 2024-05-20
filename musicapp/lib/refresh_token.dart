import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'api_endpoints.dart';
import 'dart:io';

class AuthService {
  final storage = FlutterSecureStorage();

  Future<void> refreshToken(BuildContext context) async {
    try {
      String? storedToken = await storage.read(key: 'jwtRefreshToken');
      if (storedToken != null) {
        var url = Uri.parse(REFRESH_ENDPOINT);
        var client = http.Client();
        var response = await client.post(
          url,
          headers: {
            'content-type': 'application/json',
            'Authorization': 'Bearer $storedToken',
            // Include the token as Bearer
          },
        );
        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          String newToken = jsonResponse['access_token'];
          await storage.write(key: 'jwtToken', value: newToken);
          print(newToken);
        } else if (response.statusCode == 401) {
          // Handle expired refresh token
          handleExpiredRefreshToken(context);
        } else {
          throw Exception('Failed to refresh token');
        }
      } else {
        handleExpiredRefreshToken(context);
        throw Exception('Refresh token not found');
      }
    } on SocketException {
      // No internet connection
      print('No internet connection');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No internet connection'),
          duration: Duration(seconds: 6),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Server unreachable'),
          duration: Duration(seconds: 6),
        ),
      );
      throw Exception('Error refreshing token');
    }
  }
}

Future<void> handleExpiredRefreshToken(BuildContext context) async {
  const storage = FlutterSecureStorage();
  await storage.delete(key: 'jwtToken');
  await storage.delete(key: 'jwtRefreshToken');
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const LoginPage()),
  );
}
