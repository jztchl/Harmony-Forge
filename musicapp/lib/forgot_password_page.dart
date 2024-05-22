// ignore_for_file: use_super_parameters, library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'api_endpoints.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  String errorMessage = '';
  bool otpSent = false;
  bool _newPasswordObscured =
      true; // new variable to track new password visibility
  bool _confirmPasswordObscured =
      true; // new variable to track confirm password visibility

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
    if (value != null && value.isEmpty) {
      return 'Confirm password cannot be empty';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
        .hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> sendOtp(String username) async {
    try {
      var url = Uri.parse(FORGOT_PASSWORD_ENDPOINT);
      var response = await http.post(
        url,
        body: jsonEncode({'username': username}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // OTP sent successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent to your email'),
            duration: Duration(seconds: 3),
          ),
        );
        setState(() {
          otpSent = true;
        });
      } else {
        // Failed to send OTP
        setState(() {
          errorMessage =
              'Failed to send OTP. ${json.decode(response.body)['error']}';
        });
      }
    } on SocketException {
      // No internet connection
      print('No internet connection');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection'),
          duration: Duration(seconds: 6),
        ),
      );
    } catch (e) {
      print('Error sending OTP: $e');
      setState(() {
        errorMessage = 'An error occurred. Please try again later.';
      });
    }
  }

  Future<void> resetPassword(
      String username, String otp, String newPassword) async {
    try {
      var url = Uri.parse(RESET_PASSWORD_ENDPOINT);
      // Replace 'http://your-api-url/reset_password' with your actual API endpoint

      var response = await http.post(
        url,
        body: jsonEncode({
          'username': username,
          'otp': otp,
          'new_password': newPassword,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Password reset successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successfully'),
            duration: Duration(seconds: 3),
          ),
        );
        // Navigate to login page or any other page as needed
        Navigator.pop(context);
      } else {
        // Failed to reset password
        setState(() {
          errorMessage =
              'Failed to reset password.${json.decode(response.body)['error']}';
        });
      }
    } on SocketException {
      // No internet connection
      print('No internet connection');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection'),
          duration: Duration(seconds: 6),
        ),
      );
    } catch (e) {
      print('Error resetting password: $e');
      setState(() {
        errorMessage = 'An error occurred. Please try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text('Forgot Password',
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
        child: Column(// Change SingleChildScrollView to Column
            children: [
          Expanded(
            child: SingleChildScrollView(
              // Add this line
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!otpSent) ...[
                    // Add this line
                    const Text(
                      'Enter your registered email to receive OTP',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          errorMessage = validateEmail(value) ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        String username = usernameController.text.trim();
                        if (username.isNotEmpty &&
                            validateEmail(username) == null) {
                          sendOtp(username);
                        } else {
                          setState(() {
                            errorMessage = validateEmail(username) ??
                                'Please enter your email.';
                          });
                        }
                      },
                      child: const Text('Send OTP'),
                    ),
                  ],
                  if (otpSent) ...[
                    // Add this line
                    const SizedBox(height: 20),
                    const Text(
                      'Enter Latest OTP and new password to reset',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: otpController,
                      decoration: const InputDecoration(
                        labelText: 'OTP',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: newPasswordController,
                      obscureText:
                          _newPasswordObscured, // new variable to track password visibility
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        suffixIcon: IconButton(
                          // new IconButton widget for visibility toggle
                          icon: Icon(
                            _newPasswordObscured
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _newPasswordObscured = !_newPasswordObscured;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText:
                          _confirmPasswordObscured, // new variable to track password visibility
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        suffixIcon: IconButton(
                          // new IconButton widget for visibility toggle
                          icon: Icon(
                            _confirmPasswordObscured
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _confirmPasswordObscured =
                                  !_confirmPasswordObscured;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        String username = usernameController.text.trim();
                        String otp = otpController.text.trim();
                        String newPassword = newPasswordController.text;
                        String confirmPassword = confirmPasswordController.text;

                        if (username.isNotEmpty &&
                            otp.isNotEmpty &&
                            newPassword.isNotEmpty &&
                            confirmPassword.isNotEmpty) {
                          String? passwordError =
                              validateNewPassword(newPassword);
                          if (passwordError != null) {
                            setState(() {
                              errorMessage = passwordError;
                            });
                            return;
                          }
                          if (newPassword != confirmPassword) {
                            setState(() {
                              errorMessage =
                                  'New password and confirm password do not match.';
                            });
                            return;
                          }
                          resetPassword(username, otp, newPassword);
                        } else {
                          setState(() {
                            errorMessage = 'Please fill in all fields.';
                          });
                        }
                      },
                      child: const Text('Reset Password'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        String username = usernameController.text.trim();
                        if (username.isNotEmpty &&
                            validateEmail(username) == null) {
                          sendOtp(username);
                        } else {
                          setState(() {
                            errorMessage = validateEmail(username) ??
                                'Please enter your email.';
                          });
                        }
                      },
                      child: const Text('Resend OTP'),
                    ),
                  ],
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
