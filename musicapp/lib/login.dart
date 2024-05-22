// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'registration_page.dart';
import 'api_endpoints.dart';
import 'dart:io';
import 'forgot_password_page.dart'; // Import the new screen for password recovery

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String errorMessage = '';
  final storage = const FlutterSecureStorage();
  bool _obscureText = true; // Add a bool variable for password visibility

  Future<void> loginUser(String username, String password) async {
    try {
      // var url = Uri.parse(
      //     'http://10.0.2.2:5000/login');
      var url = Uri.parse(LOGIN_ENDPOINT);
      // Replace with your API endpoint

      var client = http.Client();
      var response = await client.post(
        url,
        body: json.encode({
          'username': username,
          'password': password,
        }),
        headers: {
          'content-type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          // OR, use a custom User-Agent header
          'User-Agent': 'Custom-Agent',
        },
      );

      if (response.statusCode == 200) {
        // Login successful
        var jsonResponse = jsonDecode(response.body);
        String token = jsonResponse[
            'access_token']; // Assuming the token key in the response

        String refreshtoken = jsonResponse[
            'refresh_token']; // Assuming the token key in the response

        await storage.write(key: 'jwtToken', value: token);
        await storage.write(key: 'jwtRefreshToken', value: refreshtoken);
        print("saved");
        String? storedToken = await storage.read(key: 'jwtToken');
        print(storedToken);

        // Navigate to another page upon successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else if (response.statusCode == 400) {
        setState(() {
          errorMessage = 'please verify email';
        });
      } else {
        // Login failed
        print('Login failed: ${response.statusCode}');
        setState(() {
          errorMessage = 'Invalid username or password.';
        });
      }
    } on SocketException {
      // No internet connection
      print('No internet connection');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Error logging in: $e');
      setState(() {
        errorMessage = 'An error occurred. Please try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue
            .shade900, // Set the background color to a darker shade of blue
        title: const Text('Generate Music',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Login to Your Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Set text color
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.white, // Set prefix icon color
                          ),
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
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        obscureText:
                            _obscureText, // Use the bool variable for password visibility
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.white),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.white, // Set prefix icon color
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors
                                    .white), // Set the border color to white
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors
                                    .white), // Set the focused border color to white
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          String username = usernameController.text.trim();
                          String password = passwordController.text;

                          if (username.isEmpty || password.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text(
                                      'Username and password are required.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            // Call the loginUser function to send the username and password to the API
                            loginUser(username, password);
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.blueAccent), // Set button background color
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Colors.white), // Set text color
                        ),
                        child: const Text('Login'),
                      ),
                      if (errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have an account?',
                            style: TextStyle(
                              color: Colors.white, // Set text color
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RegistrationPage()),
                              );
                            },
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                color: Color.fromARGB(
                                    255, 0, 242, 255), // Set text color
                              ),
                            ),
                          ),
                          // Add some spacing between Register and Forgot Password
                          Flexible(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Forgot Password',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
