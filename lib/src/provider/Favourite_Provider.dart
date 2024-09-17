import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PropertyProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _bookmarkedProperties = [];
  late SharedPreferences _prefs;

  PropertyProvider({required List<String> savedBookmarks}) {
    _loadPrefs(savedBookmarks);
  }

  List<Map<String, dynamic>> get bookmarkedProperties => _bookmarkedProperties;

  Future<void> _loadPrefs(List<String> savedBookmarks) async {
    _prefs = await SharedPreferences.getInstance();
    // Load the bookmarked properties from shared preferences
    List<String>? bookmarkedPropertyKeys =
    savedBookmarks.isNotEmpty ? savedBookmarks : _prefs.getStringList('bookmarks');
    if (bookmarkedPropertyKeys != null) {
      _bookmarkedProperties = bookmarkedPropertyKeys
          .map((key) => _deserializeProperty(key))
          .toList();
      notifyListeners();
    }
  }

  void _savePrefs() {
    // Save the bookmarked property keys to shared preferences
    List<String> bookmarkedPropertyKeys = _bookmarkedProperties
        .map((property) => _serializeProperty(property))
        .toList();
    _prefs.setStringList('bookmarks', bookmarkedPropertyKeys);
  }

  String _serializeProperty(Map<String, dynamic> property) {
    // Convert the property map to a JSON string
    return json.encode(property);
  }

  Map<String, dynamic> _deserializeProperty(String key) {
    // Parse the JSON string back to a map
    return json.decode(key);
  }

  void toggleBookmark(Map<String, dynamic> property) {
    final isBookmarked = _bookmarkedProperties.contains(property);

    if (isBookmarked) {
      _bookmarkedProperties.remove(property);
    } else {
      _bookmarkedProperties.add(property);
    }

    // Save changes to shared preferences
    _savePrefs();

    notifyListeners();
  }
}
