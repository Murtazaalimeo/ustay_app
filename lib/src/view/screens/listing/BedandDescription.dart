import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../bottomnavigator.dart';

class NextPage extends StatefulWidget {
  final String propertyType;
  final String category;
  final String selectedLocation;
  final double selectedLatitude;
  final double selectedLongitude;
  final String numberController;
  final int selectedBedrooms;
  final int selectedBathrooms;
  final String sizeUnit;
  final String property;

  const NextPage({
    Key? key,
    required this.property,
    required this.propertyType,
    required this.category,
    required this.selectedLocation,
    required this.selectedLatitude,
    required this.selectedLongitude,
    required this.numberController,
    required this.selectedBedrooms,
    required this.selectedBathrooms,
    required this.sizeUnit,
  }) : super(key: key);

  @override
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();
  late TextEditingController priceController;
  late TextEditingController emailController;
  late TextEditingController descriptionController;
  late TextEditingController contactController;
  late TextEditingController nameController;
  late TextEditingController addressController;
  List<XFile>? _imageFiles;
  bool _isSaving = false;
  String? _selectedCity;

  final List<String> _cities = ['multan', 'lahore', 'fsd', 'aps','islamabad','bwl'];

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    descriptionController = TextEditingController();
    contactController = TextEditingController();
    nameController = TextEditingController();
    priceController = TextEditingController();
    addressController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Property', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Property Details'),
            _buildTextField('Property Name', nameController),
            _buildTextField('Email', emailController, hintText: 'Use email which you have used at login'),
            _buildTextField('Price', priceController),
            _buildDescriptionTextField('Property Description', descriptionController),
            _buildTextField('Contact Number', contactController),
            _buildTextField('Address', addressController),
            _buildCityDropdown(),
            const SizedBox(height: 20),
            _buildSectionHeader('Property Images'),
            _buildImagePickerButton(),
            const SizedBox(height: 10),
            if (_imageFiles != null) _buildImageGrid(),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildSaveButton(),
                const SizedBox(width: 20),
                _buildDisplayDataButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hintText}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionTextField(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Select City',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        value: _selectedCity,
        onChanged: (String? newValue) {
          setState(() {
            _selectedCity = newValue;
          });
        },
        items: _cities.map<DropdownMenuItem<String>>((String city) {
          return DropdownMenuItem<String>(
            value: city,
            child: Text(city),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImagePickerButton() {
    return ElevatedButton(
      onPressed: () async {
        final pickedFiles = await _imagePicker.pickMultiImage();
        setState(() {
          _imageFiles = pickedFiles;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        'Pick Images',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: _imageFiles!
          .map(
            (file) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: FileImage(File(file.path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
      )
          .toList(),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isSaving
          ? null
          : () async {
        setState(() {
          _isSaving = true;
        });
        await _uploadImages();
        await _saveDataToFirestore();
        setState(() {
          _isSaving = false;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: _isSaving
          ? const CircularProgressIndicator()
          : const Text(
        'Save Data',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildDisplayDataButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BottomTabNav()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        'Display Data',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Future<void> _uploadImages() async {
    try {
      List<String> imageUrls = [];

      if (_imageFiles != null && _imageFiles!.isNotEmpty) {
        for (XFile file in _imageFiles!) {
          File imageFile = File(file.path);
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          TaskSnapshot task = await _storage
              .ref('property_images/$fileName.jpg')
              .putFile(imageFile);
          String imageUrl = await task.ref.getDownloadURL();
          imageUrls.add(imageUrl);
        }
      }

      if (kDebugMode) {
        print('Image URLs: $imageUrls');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading images: $e');
      }
    }
  }

  Future<void> _saveDataToFirestore() async {
    try {
      String documentId = _firestore.collection('properties').doc().id;
      List<String> imageUrls = [];

      if (_imageFiles != null && _imageFiles!.isNotEmpty) {
        for (XFile file in _imageFiles!) {
          File imageFile = File(file.path);
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          TaskSnapshot task = await _storage
              .ref('property_images/$fileName.jpg')
              .putFile(imageFile);
          String imageUrl = await task.ref.getDownloadURL();
          imageUrls.add(imageUrl);
        }
      }

      await _firestore.collection('properties').doc(documentId).set({
        'userId': _auth.currentUser?.uid,
        'propertyType': widget.propertyType,
        'category': widget.category,
        'location': widget.selectedLocation,
        'latitude': widget.selectedLatitude,
        'longitude': widget.selectedLongitude,
        'number': widget.numberController,
        'bedrooms': widget.selectedBedrooms,
        'bathrooms': widget.selectedBathrooms,
        'sizeUnit': widget.sizeUnit,
        'property': widget.property,
        'name': nameController.text,
        'email': emailController.text,
        'price': priceController.text,
        'description': descriptionController.text,
        'contact': contactController.text,
        'address': addressController.text,
        'city': _selectedCity,
        'imageUrls': imageUrls,
      });

      if (kDebugMode) {
        print('Data saved to Firestore');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving data to Firestore: $e');
      }
    }
  }
}
