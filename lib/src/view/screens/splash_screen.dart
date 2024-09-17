import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp/src/view/screens/onboarding_screen.dart';
import 'package:fyp/src/view/screens/options.dart';
import 'bottomnavigator.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    navigateUser();
  }

  void navigateUser() async {
    await Future.delayed(const Duration(seconds: 3));

    // Check if the user is already logged in
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is already logged in
      setState(() {
        _loggedIn = true;
      });

      // Check if user data exists in Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .get();

      if (userSnapshot.exists) {
        // User data exists, navigate to appropriate screen
        if (_loggedIn) {
          // User is logged in and has visited before
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BottomTabNav()),
          );
        } else {
          // User is logged in for the first time
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  RentOptionsScreen()),
          );
        }
      }
    } else {
      // User is not logged in, navigate to LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo image
            Image.asset(
              'assets/images/fyp.png', // Replace with your image asset path
              width: 250, // Adjust image width
              height: 250, // Adjust image height
            ),
            const SizedBox(height: 20), // Add some spacing
          ],
        ),
      ),
    );
  }
}
