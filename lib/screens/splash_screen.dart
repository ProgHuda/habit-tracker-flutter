import 'package:flutter/material.dart';
import 'dart:async';
import 'package:habit_tracker_app/screens/welcome_screen.dart'; // Ensure this path matches the location of your WelcomeScreen file

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delayed navigation to Welcome Screen after 10 seconds
    Timer(const Duration(seconds: 10), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const WelcomeScreen())); // Added const keyword here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Image
            Image.asset(
              'assets/logo.png', // Relative path of your logo image
              height: 150, // Set the height as desired
              width: 150, // Set the width as desired
            ),
            const SizedBox(height: 20),
            const Text(
              '“The journey of a thousand miles begins with one step.”',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
