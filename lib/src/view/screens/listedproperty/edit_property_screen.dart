import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPropertyScreen extends StatefulWidget {
  final String propertyId;
  final Map<String, dynamic> propertyData;

  const EditPropertyScreen({
    Key? key,
    required this.propertyId,
    required this.propertyData,
  }) : super(key: key);

  @override
  _EditPropertyScreenState createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  late TextEditingController nameController;
  late TextEditingController propertyController;
  late TextEditingController propertyTypeController;
  late TextEditingController categoryController;
  late TextEditingController selectedLocationController;
  late TextEditingController selectedLatitudeController;
  late TextEditingController selectedLongitudeController;
  late TextEditingController numberController;
  late TextEditingController selectedBedroomsController;
  late TextEditingController selectedBathroomsController;
  late TextEditingController sizeUnitController;
  late TextEditingController priceController;
  late TextEditingController emailController;
  late TextEditingController descriptionController;
  late TextEditingController contactController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.propertyData['name']);
    propertyController = TextEditingController(text: widget.propertyData['property']);
    propertyTypeController = TextEditingController(text: widget.propertyData['propertyType']);
    categoryController = TextEditingController(text: widget.propertyData['category']);
    selectedLocationController = TextEditingController(text: widget.propertyData['selectedLocation']);
    selectedLatitudeController = TextEditingController(text: widget.propertyData['selectedLatitude'].toString());
    selectedLongitudeController = TextEditingController(text: widget.propertyData['selectedLongitude'].toString());
    numberController = TextEditingController(text: widget.propertyData['numberController']);
    selectedBedroomsController = TextEditingController(text: widget.propertyData['selectedBedrooms'].toString());
    selectedBathroomsController = TextEditingController(text: widget.propertyData['selectedBathrooms'].toString());
    sizeUnitController = TextEditingController(text: widget.propertyData['sizeUnit']);
    priceController = TextEditingController(text: widget.propertyData['price']);
    emailController = TextEditingController(text: widget.propertyData['email']);
    descriptionController = TextEditingController(text: widget.propertyData['propertyDescription']);
    contactController = TextEditingController(text: widget.propertyData['contactNumber']);
    addressController = TextEditingController(text: widget.propertyData['address']);
  }

  Future<void> _updateProperty() async {
    try {
      await FirebaseFirestore.instance.collection('properties').doc(widget.propertyId).update({
        'name': nameController.text,
        'property': propertyController.text,
        'propertyType': propertyTypeController.text,
        'category': categoryController.text,
        'numberController': numberController.text,
        'selectedBedrooms': int.tryParse(selectedBedroomsController.text) ?? widget.propertyData['selectedBedrooms'],
        'selectedBathrooms': int.tryParse(selectedBathroomsController.text) ?? widget.propertyData['selectedBathrooms'],
        'sizeUnit': sizeUnitController.text,
        'price': priceController.text,
        'email': emailController.text,
        'propertyDescription': descriptionController.text,
        'contactNumber': contactController.text,
        'address': addressController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property updated successfully.')),
      );
      Navigator.pop(context); // Go back to the properties list screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update property.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Property'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.black87,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField('Name', nameController),
              _buildTextField('Property', propertyController),
              _buildTextField('Property Type', propertyTypeController),
              _buildTextField('Category', categoryController),
              _buildTextField('Number Controller', numberController),
              _buildTextField('Selected Bedrooms', selectedBedroomsController, keyboardType: TextInputType.number),
              _buildTextField('Selected Bathrooms', selectedBathroomsController, keyboardType: TextInputType.number),
              _buildTextField('Size Unit', sizeUnitController),
              _buildTextField('Price', priceController),
              _buildTextField('Email', emailController),
              _buildTextField('Description', descriptionController),
              _buildTextField('Contact Number', contactController),
              _buildTextField('Address', addressController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProperty,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text('Update Property', style: TextStyle(
                color : Colors.white
                ),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
