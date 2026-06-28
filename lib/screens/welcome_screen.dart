import 'package:flutter/material.dart';
import 'package:habit_tracker_app/screens/signin_page.dart'; // Ensure this path is correct for SignInPage
import 'package:habit_tracker_app/screens/motivational_quotes_page.dart'; // Import MotivationalQuotesPage

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key}); // Convert 'key' to a super parameter

  @override
  Widget build(BuildContext context) {
    return const Scaffold( // Add const keyword here
      backgroundColor: Colors.white,
      body: SingleChildScrollView( // Wrap with SingleChildScrollView to make it scrollable
        child: WelcomeContent(), // Extracted content into a separate widget for clarity
      ),
    );
  }
}

class WelcomeContent extends StatelessWidget {
  const WelcomeContent({super.key}); // Convert 'key' to a super parameter

  @override
  Widget build(BuildContext context) {
    return Padding( // Use Padding instead of SizedBox for padding
      padding: const EdgeInsets.all(20.0), // Define your padding here
      child: SizedBox(
        height: MediaQuery.of(context).size.height, // Make the container full screen
        width: MediaQuery.of(context).size.width, // Adjust width to full screen as well
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded( // Use Expanded to take up available space
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text( // Use const for immutable Text widget
                    'Welcome to Habit Tracker!',
                    style: TextStyle( // TextStyle cannot be const since it's being passed to a non-const widget
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50), // Use const SizedBox
                  const Text( // Use const for immutable Text widget
                    'Let’s start building better habits!',
                    style: TextStyle( // TextStyle cannot be const since it's being passed to a non-const widget
                      fontSize: 20,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50), // Use const SizedBox
                  // Sign Up / Sign In Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignInPage()), // Add const for SignInPage
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15), // Add const for EdgeInsets
                    ),
                    child: const Text( // Use const for immutable Text widget
                      'Sign In / Sign Up',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Use const SizedBox
                  // Continue as Guest Button
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MotivationalQuotesPage()), // Redirect to Motivational Quotes Page
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15), // Add const for EdgeInsets
                      side: const BorderSide(color: Colors.blueAccent, width: 2), // Add const for BorderSide
                    ),
                    child: const Text( // Use const for immutable Text widget
                      'Continue as Guest',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
