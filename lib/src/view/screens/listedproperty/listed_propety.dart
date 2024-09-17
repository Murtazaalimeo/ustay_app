import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_property_screen.dart';

class UserPropertiesScreen extends StatefulWidget {
  const UserPropertiesScreen({Key? key}) : super(key: key);

  @override
  _UserPropertiesScreenState createState() => _UserPropertiesScreenState();
}

class _UserPropertiesScreenState extends State<UserPropertiesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User? _currentUser;
  List<DocumentSnapshot> _userProperties = [];

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _fetchUserProperties();
  }

  Future<void> _fetchUserProperties() async {
    if (_currentUser != null) {
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection('properties')
            .where('email', isEqualTo: _currentUser!.email)
            .get();

        setState(() {
          _userProperties = querySnapshot.docs;
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching user properties: $e');
        }
      }
    }
  }

  Future<void> _deleteProperty(String propertyId) async {
    try {
      await _firestore.collection('properties').doc(propertyId).delete();
      _fetchUserProperties(); // Refresh properties after deletion
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property deleted successfully.'),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting property: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete property.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Properties'),
        backgroundColor: Colors.deepPurple,
        elevation: 0, // No shadow
      ),
      backgroundColor: Colors.black87, // Dark background
      body: _userProperties.isEmpty
          ? const Center(
        child: Text(
          'No properties found for this user.',
          style: TextStyle(color: Colors.white),
        ),
      )
          : ListView.builder(
        itemCount: _userProperties.length,
        itemBuilder: (context, index) {
          DocumentSnapshot propertySnapshot = _userProperties[index];
          Map<String, dynamic> propertyData = propertySnapshot.data() as Map<String, dynamic>;

          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: Colors.grey[900], // Dark card background
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              title: Text(
                propertyData['name'] ?? 'Unnamed Property',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    'Type: ${propertyData['propertyType']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Category: ${propertyData['category']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Location: ${propertyData['selectedLocation']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Price: ${propertyData['price']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Contact: ${propertyData['contactNumber']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  // Add more property details to display
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    color: Colors.blue,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPropertyScreen(
                            propertyId: propertySnapshot.id,
                            propertyData: propertyData,
                          ),
                        ),
                      ).then((_) => _fetchUserProperties()); // Refresh properties after editing
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
                          content: const Text(
                            'Are you sure you want to delete this property?',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.deepPurple,
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close confirmation dialog
                                _deleteProperty(propertySnapshot.id); // Delete property
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              onTap: () {
                // Handle property detail tap (e.g., navigate to a detail screen)
              },
            ),
          );
        },
      ),
    );
  }
}
