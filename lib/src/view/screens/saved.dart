// favorite_places_screen.dart

import 'package:flutter/material.dart';
import 'package:fyp/src/provider/Favourite_Provider.dart';
import 'package:fyp/src/view/screens/propertydisplay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritePlacesScreen extends StatefulWidget {
  @override
  _FavoritePlacesScreenState createState() => _FavoritePlacesScreenState();
}

class _FavoritePlacesScreenState extends State<FavoritePlacesScreen> {
  late PropertyProvider propertyProvider;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      // Initialize PropertyProvider with the saved bookmarks from shared preferences
      propertyProvider = PropertyProvider(savedBookmarks: prefs.getStringList('bookmarks') ?? []);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Favorite Places'),
        ),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 17),
        backgroundColor: Colors.black87,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<PropertyProvider>(
            builder: (context, provider, child) {
              List<Map<String, dynamic>> bookmarkedProperties =
                  provider.bookmarkedProperties;

              return ListView.builder(
                itemCount: bookmarkedProperties.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> property = bookmarkedProperties[index];
                  String placeName = _generateBookmarkKey(property);

                  return FavoritePlaceItem(
                    placeName: placeName,
                    onTap: () {
                      // Navigate to the details screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PropertyDetailsScreen(
                            property: property,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _generateBookmarkKey(Map<String, dynamic> property) {
    // Implement your logic to generate a unique key for a bookmarked property
    // This should be similar to the logic used in PropertyDetailsScreen
    return "${property['id']}_${property['name']}_${property['selectedLocation']}";
  }
}

class FavoritePlaceItem extends StatelessWidget {
  final String placeName;
  final VoidCallback onTap;

  const FavoritePlaceItem({
    required this.placeName,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.indigo),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          placeName,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
