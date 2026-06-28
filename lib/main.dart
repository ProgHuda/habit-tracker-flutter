import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:habit_tracker_app/screens/splash_screen.dart';

// Your Firebase configuration
const firebaseConfig = {
  'apiKey': "AIzaSyBHZlzpYoCwTY2z6vhcvmwxi0PtT4SD_fE",
  'authDomain': "tracker-a3b81.firebaseapp.com",
  'projectId': "tracker-a3b81",
  'storageBucket': "tracker-a3b81.firebasestorage.app",
  'messagingSenderId': "451536688359",
  'appId': "1:451536688359:web:dd079b6fd3d4270f413e42",
  'measurementId': "G-62J5DGQ6WW",
  'databaseURL': "https://tracker-a3b81-default-rtdb.firebaseio.com", // Add database URL
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Ensures Flutter is properly initialized

  // Initialize Firebase with your custom configuration for Web
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: firebaseConfig['apiKey'] as String,
      authDomain: firebaseConfig['authDomain'] as String,
      projectId: firebaseConfig['projectId'] as String,
      storageBucket: firebaseConfig['storageBucket'] as String,
      messagingSenderId: firebaseConfig['messagingSenderId'] as String,
      appId: firebaseConfig['appId'] as String,
      measurementId: firebaseConfig['measurementId'] as String,
      databaseURL: firebaseConfig['databaseURL'] as String, // Use database URL
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
