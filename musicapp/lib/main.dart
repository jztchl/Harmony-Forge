// ignore_for_file: prefer_const_constructors, use_super_parameters, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'generate_music_page.dart';
import 'generated_files_page.dart';
import 'convert_instrument_page.dart';
import 'generate_multi_music_page.dart';
import 'feedback.dart';
import 'login.dart';
import 'refresh_token.dart';
import 'dart:async';
import 'dart:math';
import 'change_password_page.dart';

Timer? _timer;
String? displayName;

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Add this line
  Widget homePage = const LoginPage();
  final storage = FlutterSecureStorage();
  String? jwtRefreshToken = await storage.read(key: 'jwtRefreshToken');
  if (jwtRefreshToken != null) {
    homePage = const MainPage();
  }
  runApp(MyApp(homePage: homePage));
}

class MyApp extends StatelessWidget {
  final Widget homePage;

  const MyApp({Key? key, required this.homePage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harmony Forge',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Quicksand',
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          labelLarge: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      home: homePage,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  bool _isTokenRefreshed = false;
  final List<IconData> _icons = [
    Icons.music_note,
    Icons.folder,
    Icons.swap_horiz,
    Icons.music_note_rounded,
    Icons.lock_outline,
  ];

  final List<String> _titles = [
    'Generate Music',
    'Generate Multi-Instrument Music',
    'Generated Files',
    'Convert Instrument',
    'Change Password',
  ];

  final List<Widget> _screens = [
    const GenerateMusicPage(),
    const GenerateMultiInstrumentMusicPage(),
    const GeneratedFilesPage(),
    const ConvertInstrumentPage(),
    const ChangePasswordPage(),
  ];

  @override
  void initState() {
    super.initState();

    if (!_isTokenRefreshed) {
      onLoadRefresh(context);
      periodicTokenRefresh(context);
      _isTokenRefreshed = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call the token refresh function here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue
            .shade900, // Set the background color to a darker shade of blue
        title: const Text(
          'Harmony Forge',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white, // Set the text color to white
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              if (mounted) {
                logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
            color: Colors.white, // Set the icon color to white
          ),
        ],
        elevation: 0, // Remove the app bar shadow
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Icon(
              Icons.music_note,
              size: 48,
              color: Colors.white,
            ),
            const Text(
              'Welcome',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<String?>(
              future: decodeJwtToken(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text(
                    snapshot.data ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            CarouselSlider(
              items: _icons.asMap().entries.map((entry) {
                int index = entry.key;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => _screens[index]),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          entry.value,
                          size: 64.0,
                          color: index == _currentIndex
                              ? _getRandomColor()
                              : Colors.white,
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          _titles[index],
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: index == _currentIndex
                                ? _getRandomColor()
                                : Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                height: 200.0,
                enlargeCenterPage: true,
                autoPlay: false,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 0.8,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _icons.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _carouselController.animateToPage(entry.key),
                  child: Container(
                    width: 12.0,
                    height: 12.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(_currentIndex == entry.key ? 0.9 : 0.4),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FeedbackPopup();
                  },
                );
              },
              label: const Text(
                'Give Feedback',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.feedback),
              backgroundColor: _getRandomColor(),
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final CarouselController _carouselController = CarouselController();

  Color _getRandomColor() {
    return Color.fromRGBO(
      Random().nextInt(256),
      Random().nextInt(256),
      Random().nextInt(256),
      1,
    );
  }
}

void onLoadRefresh(BuildContext context) {
  try {
    AuthService authService = AuthService();
    authService.refreshToken(context);
    print('Token refreshed successfully');
  } catch (e) {
    print('Error refreshing token: $e');
  }
}

void periodicTokenRefresh(BuildContext context) {
  const Duration interval =
      Duration(minutes: 165); // Set the interval to 3 seconds for testing
  // Declare the timer variable outside the function

  _timer = Timer.periodic(interval, (Timer timer) async {
    try {
      AuthService authService = AuthService();
      await authService.refreshToken(context);
      print('Token refreshed successfully');
    } catch (e) {
      print('Error refreshing token: $e');
      _timer?.cancel(); // Cancel the timer if it's not null
    }
  });

  // Cancel the timer when the user logs out
  // Assuming you have a logout function that calls this method
}

Future<String?> decodeJwtToken() async {
  const storage = FlutterSecureStorage();
  String? jwtRefreshToken = await storage.read(key: 'jwtRefreshToken');
  if (jwtRefreshToken != null) {
    Map<String, dynamic> decodedToken = Jwt.parseJwt(jwtRefreshToken);
    if (decodedToken.containsKey('sub') &&
        decodedToken['sub'] is Map<String, dynamic>) {
      Map<String, dynamic> sub = decodedToken['sub'];
      if (sub.containsKey('name')) {
        return sub['name'];
      }
    }
  }
  return null;
}

void logout() async {
  const storage = FlutterSecureStorage();
  await storage.delete(key: 'jwtToken');
  await storage.delete(key: 'jwtRefreshToken');

  _timer?.cancel(); // Cancel the timer if it's not null
  // Perform logout operations here
}
