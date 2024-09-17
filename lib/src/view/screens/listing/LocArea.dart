import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'BedandDescription.dart';


class LocationAreaSelectionScreen extends StatefulWidget {
  final String property;
  final String propertyType;
  final String category;

  LocationAreaSelectionScreen({
    Key? key,
    required this.property,
    required this.propertyType,
    required this.category,
  }) : super(key: key);

  @override
  _LocationAreaSelectionScreenState createState() =>
      _LocationAreaSelectionScreenState();
}

class _LocationAreaSelectionScreenState
    extends State<LocationAreaSelectionScreen> {
  TextEditingController numberController = TextEditingController();
  String selectedSizeUnit = 'Square Feet';
  String selectedLocation = '';
  double selectedLatitude = 0.0;
  double selectedLongitude = 0.0;
  String selectedArea = '';
  late TextEditingController searchController;

  Map<String, List<String>> areasByPropertyType = {
    'Houses': ['Area A', 'Area B', 'Area C', 'Area D'],
    'Plots': ['Area X', 'Area Y', 'Area Z', 'Area P'],
    'Commercial': ['Area 1', 'Area 2', 'Area 3', 'Area 4'],
  };

  List<String> areas = [];
  int selectedBedrooms = 0;
  int selectedBathrooms = 0;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    areas = areasByPropertyType[widget.propertyType] ?? [];
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterLocations(String query) {
    // TODO: Implement location filtering logic if needed
  }

  Future<void> _selectLocationOnMap() async {
    try {
      final Map<String, dynamic>? result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MapScreen()),
      );

      if (result != null &&
          result.containsKey('selectedLocation') &&
          result.containsKey('latitude') &&
          result.containsKey('longitude') &&
          result.containsKey('selectedArea')) {
        setState(() {
          selectedLocation = result['selectedLocation'];
          selectedLatitude = result['latitude'];
          selectedLongitude = result['longitude'];
          selectedArea = result['selectedArea'];
          searchController.text = selectedLocation;
          numberController.text= numberController as String;
        });
      }
    } catch (e) {
      print('Error selecting location on map: $e');
      // Handle error as needed
    }
  }

  void _navigateToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NextPage(
          property: widget.property,
          propertyType: widget.propertyType,
          category: widget.category,
          selectedLocation: selectedLocation,
          selectedLatitude: selectedLatitude,
          selectedLongitude: selectedLongitude,
          sizeUnit: selectedSizeUnit,
          selectedBedrooms: selectedBedrooms,
          selectedBathrooms: selectedBathrooms,
          numberController: numberController.text,
        ),
      ),
    );
  }

  Widget buildTextField() {
    return TextFormField(
      controller: searchController,
      readOnly: true,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: 'Selected Location',
        suffixIcon: const Icon(Icons.location_on),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.indigo),
        ),
      ),
    );
  }

  Widget buildBuiltInOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Area Size:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: numberController, // Use your controller if needed
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter Area Size',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.indigo),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: selectedSizeUnit,
              onChanged: (String? newValue) {
                setState(() {
                  selectedSizeUnit = newValue!;
                });
              },
              items: ['Square Feet', 'Square Meter', 'Marla', 'Kanal']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (widget.propertyType == 'Houses')
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'House Details:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  buildDropdownButton(
                    label: 'Bedrooms',
                    value: selectedBedrooms,
                    onChanged: (value) {
                      setState(() {
                        selectedBedrooms = value as int;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  buildDropdownButton(
                    label: 'Bathrooms',
                    value: selectedBathrooms,
                    onChanged: (value) {
                      setState(() {
                        selectedBathrooms = value as int;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget buildDropdownButton({
    required String label,
    required int value,
    required ValueChanged<int?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButton<int>(
          value: value,
          onChanged: onChanged,
          items: List.generate(
            6,
                (index) => DropdownMenuItem<int>(
              value: index,
              child: Text('$index'),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSelectLocationButton() {
    return ElevatedButton(
      onPressed: _selectLocationOnMap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(12.0),
        child: Text(
          'Select Location on Map',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget buildNextButton() {
    return ElevatedButton(
      onPressed: _navigateToNextPage,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(12.0),
        child: Text(
          'Next',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Property',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Selected Property: ${widget.propertyType} - ${widget.category}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              buildTextField(),
              const SizedBox(height: 20),
              const Text(
                'Built-in Options for Areas:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              buildBuiltInOptions(),
              const SizedBox(height: 20),
              buildSelectLocationButton(),
              const SizedBox(height: 20),
              buildNextButton(),
            ],
          ),
        ),
      ),
    );

  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LatLng selectedLocation = const LatLng(30.181459, 71.492157);
  String selectedArea = '';
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Widget buildSearchTextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchController,
        decoration: const InputDecoration(
          hintText: 'Search Location',
          suffixIcon: Icon(Icons.search),
        ),
        onChanged: (query) async {
          try {
            List<Location> locations = await locationFromAddress(query);
            if (locations.isNotEmpty) {
              mapController?.animateCamera(
                CameraUpdate.newLatLng(
                  LatLng(locations.first.latitude, locations.first.longitude),
                ),
              );
            }
          } catch (e) {
            if (kDebugMode) {
              print('Error searching location: $e');
            }
            // Handle error as needed
          }
        },
      ),
    );
  }

  Widget buildMap() {
    return Expanded(
      child: GoogleMap(
        onMapCreated: (controller) {
          setState(() {
            mapController = controller;
          });
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(30.1864, 71.4886),
          zoom: 15,
        ),
        onTap: (position) {
          setState(() {
            selectedLocation = position;
          });
        },
        markers: {
          Marker(
            markerId: const MarkerId('selectedLocation'),
            position: selectedLocation,
            infoWindow: const InfoWindow(
              title: 'Selected Location',
            ),
          ),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select location',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          buildSearchTextField(),
          buildMap(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            List<Placemark> placemarks = await placemarkFromCoordinates(
              selectedLocation.latitude,
              selectedLocation.longitude,
            );
            String selectedAddress = placemarks.first.name ?? '';
            Navigator.pop(
              context,
              {
                'selectedLocation': selectedAddress,
                'latitude': selectedLocation.latitude,
                'longitude': selectedLocation.longitude,
                'selectedArea': selectedArea,
              },
            );
          } catch (e) {
            print('Error getting address from coordinates: $e');
            // Handle error as needed
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
