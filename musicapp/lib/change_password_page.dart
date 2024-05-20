import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  String errorMessage = '';
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> changePassword(String oldPassword, String newPassword) async {
    final storage = const FlutterSecureStorage();
    String? storedToken = await storage.read(key: 'jwtToken');
    try {
      var url = Uri.parse(CHANGE_PASSWORD_ENDPOINT);
      var response = await http.post(
        url,
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $storedToken',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password changed successfully'),
            duration: Duration(seconds: 3),
          ),
        );
        // Navigate to login page or any other page as needed
        Navigator.pop(context);
      } else {
        setState(() {
          errorMessage = 'Failed to change password. Please try again later.';
        });
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
      print('Error changing password: $e');
      setState(() {
        errorMessage = 'An error occurred. Please try again later.';
      });
    }
  }

  String? validateNewPassword(String? value) {
    if (value != null && value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (value != null && !RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (value != null && !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one symbol';
    }
    if (value != null && !RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one capital letter';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text('Change Password',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.white,
            )),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Enter your old password and new password to change',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: oldPasswordController,
                        obscureText: _obscureOldPassword,
                        decoration: InputDecoration(
                          labelText: 'Old Password',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors
                                    .white), // Set the border color to white
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors
                                    .white), // Set the focused border color to white
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureOldPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureOldPassword = !_obscureOldPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your old password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: _obscureNewPassword,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors
                                    .white), // Set the border color to white
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors
                                    .white), // Set the focused border color to white
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                        ),
                        validator: validateNewPassword,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors
                                    .white), // Set the border color to white
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors
                                    .white), // Set the focused border color to white
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            String oldPassword =
                                oldPasswordController.text.trim();
                            String newPassword = newPasswordController.text;
                            changePassword(oldPassword, newPassword);
                          }
                        },
                        child: Text('Change Password'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
