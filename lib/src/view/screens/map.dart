import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Property {
  final String id;
  final String name;
  final double selectedLatitude;
  final double selectedLongitude;
  final String price;
  final String email;
  final String contactNumber;
  final String description;
  List<String> imageUrls;

  Property({
    required this.id,
    required this.name,
    required this.selectedLatitude,
    required this.selectedLongitude,
    required this.price,
    required this.email,
    required this.contactNumber,
    required this.description,
    List<String>? imageUrls,
  }) : imageUrls = imageUrls ?? [];

  String get placeholderImageUrl => 'assets/images/backgroung2.jpg';
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  List<Property> propertyList = [];
  LocationData? _currentLocation;
  Set<Marker> _markers = {};

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(30.19679000, 71.47824000),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _fetchDataAndMarkers();
    _getUserLocation();
  }

  Future<void> _fetchDataAndMarkers() async {
    await fetchData();
    _createMarkers().then((markers) {
      setState(() {
        _markers = markers;
      });
    });
  }

  Future<void> fetchData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('properties').get();

      setState(() {
        propertyList = querySnapshot.docs
            .map((doc) => Property(
          id: doc.id,
          name: doc['name'],
          selectedLatitude: doc['selectedLatitude'] ?? 0.0,
          selectedLongitude: doc['selectedLongitude'] ?? 0.0,
          price: doc['price'],
          email: doc['email'],
          contactNumber: doc['contactNumber'],
          description:  doc['propertyDescription']
        ))
            .toList();
      });

      await fetchImagesForProperties();
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching data: $error');
      }
    }
  }

  Future<void> fetchImagesForProperties() async {
    for (Property property in propertyList) {
      List<String> imageUrls = await fetchImagesForProperty(property.id);
      setState(() {
        property.imageUrls = imageUrls;
      });
    }
  }

  Future<List<String>> fetchImagesForProperty(String propertyId) async {
    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      Reference propertyImagesRef = storage.ref().child('properties/$propertyId/images/');

      ListResult result = await propertyImagesRef.listAll();

      List<String> imageUrls = await Future.wait(result.items.map((Reference ref) async {
        return await ref.getDownloadURL();
      }));

      if (kDebugMode) {
        print('Fetched image URLs for property $propertyId: $imageUrls');
      }

      return imageUrls;
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching images for property $propertyId: $error');
      }
      return [];
    }
  }

  Future<BitmapDescriptor> _getCustomMarkerIcon(String imageUrl) async {
    final ImageConfiguration imageConfiguration = createLocalImageConfiguration(context);
    return await BitmapDescriptor.fromAssetImage(imageConfiguration, imageUrl);
  }

  Future<Set<Marker>> _createMarkers() async {
    Set<Marker> markers = {};
    for (Property property in propertyList) {
      final BitmapDescriptor customIcon = await _getCustomMarkerIcon('assets/images/hos3.png');
      markers.add(
        Marker(
          markerId: MarkerId(property.id),
          position: LatLng(
            property.selectedLatitude,
            property.selectedLongitude,
          ),
          icon: customIcon,
          onTap: () {
            _showPropertyDetailsModal(property);
          },
        ),
      );
    }
    if (_currentLocation != null) {
      final userLocationIcon = await _getCustomMarkerIcon('assets/images/loc3.png');
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          icon: userLocationIcon,
        ),
      );
    }
    return markers;
  }

  Future<void> _showPropertyDetailsModal(Property property) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (property.imageUrls.isNotEmpty)
                  _buildImageSlider(property.imageUrls, property.placeholderImageUrl),
                if (property.imageUrls.isEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      property.placeholderImageUrl,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  property.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.attach_money, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      property.price,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.email, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        property.email,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      property.contactNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  property.description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed:  () async {
                    String emailAddress = property.email ?? '';
                    String emailSubject = "Regarding Test";
                    String body = "This is the body";
                    String query =
                        'mailto:$emailAddress?subject=${Uri.encodeComponent(emailSubject)}&body=${Uri.encodeComponent(body)}';

                    try {
                      if (await canLaunchUrlString(query)) {
                        await launchUrlString(query);
                      } else {
                        throw 'Could not launch email';
                      }
                    } catch (e) {
                      debugPrint('Error launching email: $e');
                    }
                  },
                  icon: const Icon(Icons.contact_mail),
                  label: const Text('Contact'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSlider(List<String> imageUrls, String placeholderImageUrl) {
    return SizedBox(
      height: 200.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          String imageUrl = imageUrls[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => Image.asset(
                  placeholderImageUrl,
                  width: 160.0,
                  height: 160.0,
                  fit: BoxFit.cover,
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                width: 160.0,
                height: 160.0,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _getUserLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = currentLocation;
        _updateUserLocationMarker();
      });
    });
  }

  Future<void> _updateUserLocationMarker() async {
    if (_currentLocation != null) {
      final userLocationIcon = await _getCustomMarkerIcon('assets/images/loc3.png');
      setState(() {
        _markers.removeWhere((marker) => marker.markerId.value == 'user_location');
        _markers.add(
          Marker(
            markerId: const MarkerId('user_location'),
            position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
            icon: userLocationIcon,
          ),
        );
      });
    }
  }

  Future<void> _moveToUserLocation() async {
    if (_currentLocation != null) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map Screen"),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D001A),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _moveToUserLocation,
        label: const Text(
          'My Location',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: const Icon(Icons.location_on),
        backgroundColor: Colors.deepPurple, // Change the color as desired
        foregroundColor: Colors.white, // Icon and text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4.0, // Shadow elevation for a better visual effect
      ),
    );
  }
}
