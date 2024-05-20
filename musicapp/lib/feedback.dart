import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:html_unescape/html_unescape.dart';
import 'dart:io';
import 'api_endpoints.dart';

class FeedbackPopup extends StatelessWidget {
  final TextEditingController feedbackController = TextEditingController();

  FeedbackPopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors
          .blue.shade900, // Set the background color to a darker shade of blue
      title: Text(
        'Feedback',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Set the text color to white
          fontFamily: 'Quicksand', // Set the font family to Quicksand
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          TextFormField(
            controller: feedbackController,
            decoration: InputDecoration(
              hintText: 'Enter your feedback...',
              hintStyle: TextStyle(
                color: Colors.white, // Set the hint text color to white
                fontFamily: 'Quicksand', // Set the font family to Quicksand
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none, // Remove the border
              ),
              filled: true,
              fillColor: Colors.grey[200]!.withOpacity(
                  0.3), // Set the fill color to a lighter shade of grey with 30% opacity
            ),
            maxLines: 5,
            style: TextStyle(
              color: Colors.white, // Set the text color to white
              fontFamily: 'Quicksand', // Set the font family to Quicksand
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              String sanitizedMessage = sanitizeInput(feedbackController.text);
              if (sanitizedMessage.isNotEmpty) {
                await sendFeedback(context,
                    sanitizedMessage); // Call sendFeedback with sanitized text and context
                Navigator.of(context).pop(); // Close the dialog
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter valid feedback'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.purple), // Set the background color to purple
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(vertical: 16),
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            child: Text(
              'Send',
              style: TextStyle(
                color: Colors.white, // Set the text color to white
                fontSize: 18,
                fontFamily: 'Quicksand', // Set the font family to Quicksand
              ),
            ),
          ),
        ],
      ),
    );
  }

  String sanitizeInput(String input) {
    // Basic input sanitization using HTML unescape to escape HTML characters
    HtmlUnescape htmlUnescape = HtmlUnescape();
    String sanitized = htmlUnescape.convert(input);
    return sanitized.trim(); // Trim leading and trailing whitespace
  }

  Future<void> sendFeedback(BuildContext context, String message) async {
    String apiUrl = FEEDBACK_ENDPOINT; // Replace with your API URL
    final storage = const FlutterSecureStorage();
    String? storedToken = await storage.read(key: 'jwtToken');
    final client = http.Client();

    try {
      var response = await client.post(
        Uri.parse(apiUrl),
        body: json.encode({
          'message': message, // Use the provided message
        }),
        headers: {
          'content-type': 'application/json',
          'Authorization': 'Bearer $storedToken',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Feedback sent successfully'),
            duration: Duration(seconds: 3),
          ),
        );
        print('Feedback sent successfully');
      } else {
        print('Error sending feedback - Status Code: ${response.statusCode}');
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
      print('Exception sending feedback: $e');
    } finally {
      client.close();
    }
  }
}
