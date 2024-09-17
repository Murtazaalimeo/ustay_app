import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/src/view/screens/chatlists.dart';
import 'package:fyp/src/view/screens/login/new%20log/LoginScree.dart';
import 'package:fyp/src/view/screens/profile.dart';
import 'listedproperty/listed_propety.dart';

class ProfileScreen extends StatelessWidget {
  static String routeName = "/profile";

  const ProfileScreen({Key? key}) : super(key: key);

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    } catch (e) {
      if (kDebugMode) {
        print("Error signing out: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D001A),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                var userData = snapshot.data!.data() as Map<String, dynamic>;
                String profileImageUrl = userData['profileImageUrl'] ?? '';
                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(screenSize.width * 0.02),
                      child: CircleAvatar(
                        radius: screenSize.width * 0.1,
                        backgroundImage: profileImageUrl.isNotEmpty
                            ? NetworkImage(profileImageUrl)
                            : const AssetImage('assets/images/avatar.png') as ImageProvider,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    _buildInfoItem('Name', '${userData['firstName']} ${userData['lastName']}', screenSize),
                    SizedBox(height: screenSize.height * 0.01),
                    _buildInfoItem('Email', user.email ?? '', screenSize),
                    SizedBox(height: screenSize.height * 0.01),
                    _buildInfoItem('Address', userData['address'] ?? '', screenSize),
                    SizedBox(height: screenSize.height * 0.01),
                    _buildInfoItem('Contact No', userData['contactNo'] ?? '', screenSize),
                  ],
                );
              },
            ),
            SizedBox(height: screenSize.height * 0.02),
            _buildButton('Edit Profile', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
            }, screenSize),
            SizedBox(height: screenSize.height * 0.01),
            _buildButton('Listed Property', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserPropertiesScreen()));
            }, screenSize),
            SizedBox(height: screenSize.height * 0.01),
            _buildButton('Chats', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ChatListScreen()));
            }, screenSize),
            const Spacer(),
            _buildLogoutButton(context),
          ],
        ),
      ),
      backgroundColor: Colors.black87,
    );
  }

  Widget _buildInfoItem(String label, String value, Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenSize.width * 0.02),
        border: Border.all(color: Colors.deepPurple, width: screenSize.width * 0.005),
      ),
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.01, horizontal: screenSize.width * 0.03),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.deepPurple,
              fontSize: screenSize.width * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontSize: screenSize.width * 0.035,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed, Size screenSize) {
    return SizedBox(
      width: screenSize.width * 0.6, // Use 60% of screen width for button width
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
          elevation: 3,
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.03, vertical: screenSize.height * 0.015),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenSize.width * 0.02)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: screenSize.width * 0.035),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return TextButton(
      onPressed: () => _logout(context),
      child: Text(
        'Log Out',
        style: TextStyle(color: Colors.red, fontSize: MediaQuery.of(context).size.width * 0.035),
      ),
    );
  }
}
