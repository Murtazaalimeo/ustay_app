import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fyp/src/view/screens/notification_page.dart';
import 'package:fyp/src/view/screens/propertydisplay.dart';
import 'package:persistent_shopping_cart/model/cart_model.dart';
import 'package:persistent_shopping_cart/persistent_shopping_cart.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../payment/payment2.dart';
import '../cart/shoppingcart.dart';
import '../options.dart';
import '../userchatroom.dart';

class Display extends StatelessWidget {
  const Display({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('notifications').where('isRead', isEqualTo: false).snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              int unreadCount = 0;
              if (snapshot.hasData) {
                unreadCount = snapshot.data!.docs.length;
              }

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white, size: 30,),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsPage(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 15,
                          minHeight: 15,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 7,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RentOptionsScreen()),
              );
            },
            icon: const Icon(Icons.add, size: 30, color: Colors.white,), // Use any icon you want here
          ),
          const SizedBox(width: 20.0),
          PersistentShoppingCart().showCartItemCountWidget(
            cartItemCountWidgetBuilder: (itemCount) => IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartView()),
                );
              },
              icon: Badge(
                label: Text(itemCount.toString()),
                child: const Icon(Icons.shopping_bag_outlined, size: 32, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 20.0),
        ],
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D001A),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: const PropertyList(),
    );
  }
}

class PropertyList extends StatefulWidget {
  const PropertyList({super.key});

  @override
  _PropertyListState createState() => _PropertyListState();
}

class _PropertyListState extends State<PropertyList> {
  late Future<List<Map<String, dynamic>>> properties;
  String selectedTransaction = 'All'; // Default option
  String selectedPropertyType = 'All'; // Default option
  String selectedCategory = 'All'; // Default option
  String selectedCity = 'All'; // Default option

  @override
  void initState() {
    super.initState();
    properties = fetchData();
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('properties').get();

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> _filterData() async {
    setState(() {
      properties = _fetchFilteredData();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchFilteredData() async {
    Query query = FirebaseFirestore.instance.collection('properties');

    if (selectedTransaction != 'All') {
      query = query.where('property', isEqualTo: selectedTransaction);
    }

    if (selectedPropertyType != 'All') {
      query = query.where('propertyType', isEqualTo: selectedPropertyType);
    }

    if (selectedCategory != 'All') {
      query = query.where('category', isEqualTo: selectedCategory);
    }

    if (selectedCity != 'All') {
      query = query.where('city', isEqualTo: selectedCity);
    }

    QuerySnapshot querySnapshot = await query.get();

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildLabeledDropdown(
                      'Transaction Type',
                      selectedTransaction,
                      ['All', 'Sell Property', 'Rent Property'],
                          (String? newValue) {
                        setState(() {
                          selectedTransaction = newValue!;
                          _filterData();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLabeledDropdown(
                      'Property Type',
                      selectedPropertyType,
                      ['All', 'Houses', 'Plots', 'Commercial'],
                          (String? newValue) {
                        setState(() {
                          selectedPropertyType = newValue!;
                          selectedCategory = 'All'; // Reset category when property type changes
                          _filterData();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildLabeledDropdown(
                'Category',
                selectedCategory,
                _getCategoryList(),
                    (String? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                    _filterData();
                  });
                },
              ),
              const SizedBox(height: 8),
              _buildLabeledDropdown(
                'City',
                selectedCity,
                _getCityList(),
                    (String? newValue) {
                  setState(() {
                    selectedCity = newValue!;
                    _filterData();
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: properties,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No properties available.'),
                );
              } else {
                List<Map<String, dynamic>> propertyList = snapshot.data!;
                return ListView.builder(
                  itemCount: propertyList.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> property = propertyList[index];
                    return PropertyListItem(property: property);
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  List<String> _getCategoryList() {
    switch (selectedPropertyType) {
      case 'Houses':
        return ['All', 'Home', 'Flat', 'Upper Portion', 'Lower Portion', 'Farm House', 'Room'];
      case 'Plots':
        return ['All', 'Residential Plot', 'Commercial Plot', 'Plot File', 'Agricultural Land', 'Industrial Land', 'Plot Foam'];
      case 'Commercial':
        return ['All', 'Furnished Offices', 'New Offices', 'Small Offices', 'New Shops', 'Commercial Others'];
      default:
        return ['All'];
    }
  }

  List<String> _getCityList() {
    // You can fetch the city list dynamically from the database or hardcode a list
    // For example purposes, a static list is provided here
    return  ['All','multan', 'lahore', 'fsd', 'aps','islamabad','bwl'];
  }

  Widget _buildLabeledDropdown(
      String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.deepPurple[50],
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: Colors.deepPurple),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class PropertyListItem extends StatelessWidget {
  final Map<String, dynamic> property;

  const PropertyListItem({
    Key? key,
    required this.property,
  }) : super(key: key);

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  Future<bool> checkPaymentStatus() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      // Fetch user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('payment')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // Check if paymentComplete field is true
        return userDoc.get('paymentComplete') ?? false;
      }

      return false; // Default to false if user document doesn't exist
    } catch (e) {
      print('Error checking payment status: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSoldOrRented = property['paymentComplete'] == true;
    String statusText = property['property'] == 'Sell Property' ? 'Sold' : 'Rented';

    return InkWell(
      onTap: () async {
        bool isPaymentComplete = await checkPaymentStatus();

        if (isPaymentComplete) {
          // Payment is complete, navigate to property details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyDetailsScreen(property: property),
            ),
          );
        } else {
          // Payment is not complete, show dialog to prompt payment
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Payment Required'),
                content: const Text(
                  'Please complete the payment to view property details.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      // Navigate to payment screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Payment2(totalAmount: 20),
                        ),
                      );
                    },
                    child: const Text('Make Payment'),
                  ),
                ],
              );
            },
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.all(12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.indigo, width: 1.5),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.phone, color: Colors.indigo),
                  onPressed: () async {
                    String contact = property['contactNumber'] ?? '';
                    String url = 'tel:$contact';

                    try {
                      if (await canLaunchUrlString(url)) {
                        await launchUrlString(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    } catch (e) {
                      print('Error launching phone: $e');
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.email, color: Colors.indigo),
                  onPressed: () async {
                    String emailAddress = property['email'] ?? '';
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
                ),
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.indigo),
                  onPressed: () async {
                    try {
                      // Fetch the user with a matching email
                      DocumentSnapshot userSnapshot = await FirebaseFirestore
                          .instance
                          .collection('users')
                          .doc(property['email'])
                          .get();

                      if (userSnapshot.exists) {
                        // Get the user's information
                        Map<String, dynamic> matchedUserInfo =
                        userSnapshot.data() as Map<String, dynamic>;

                        // Open the chat room screen with the matched user's information
                        String roomId = chatRoomId(
                          FirebaseAuth.instance.currentUser!.displayName!,
                          matchedUserInfo['name'] ?? '',
                        );

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatRoom(
                              chatRoomId: roomId,
                              userMap: matchedUserInfo,
                              user: null,
                            ),
                          ),
                        );
                      } else {
                        // Handle the case when no user is found with a matching email
                        if (kDebugMode) {
                          print('No user found with a matching email.');
                        }
                      }
                    } catch (e) {
                      if (kDebugMode) {
                        print('Error fetching user: $e');
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              height: 200.0, // Adjust the height as needed
              child: property['images'] != null &&
                  (property['images'] as List).isNotEmpty
                  ? PageView.builder(
                itemCount: (property['images'] as List).length,
                itemBuilder: (context, index) {
                  String imageUrl = property['images'][index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 150.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              )
                  : Container(
                width: double.infinity,
                height: 150.0,
                color: Colors.grey.shade300, // Placeholder color
                child: const Center(
                  child: Text(
                    'Image not available',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              property['property'] ?? '',
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Email: ${property['email'] ?? ''}', // Display the email
              style: const TextStyle(fontSize: 14.0, color: Colors.black),
            ),
            const SizedBox(height: 4.0),
            Text(
              "Area: ${property["numberController"]} ${property["sizeUnit"]}",
              style: const TextStyle(fontSize: 14.0, color: Colors.black),
            ),
            const SizedBox(height: 4.0),
            Text(
              "Price: ${property["price"]}",
              style: const TextStyle(fontSize: 14.0, color: Colors.black),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Contact no: ${property['contactNumber'] ?? ''}',
              // Display the contact number
              style: const TextStyle(fontSize: 14.0, color: Colors.black),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Category: ${property['category']}',
              style: const TextStyle(fontSize: 14.0, color: Colors.black87),
            ),
            const SizedBox(height: 8.0),
            isSoldOrRented
                ? Container(
              padding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusText,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            )
                : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FutureBuilder<bool>(
                      future: checkPaymentStatus(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator(); // Loading indicator while waiting
                        }
                        if (snapshot.data == false) {
                          return ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const Payment2(totalAmount: 20),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.indigo,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text(
                              'Pay',
                              style: TextStyle(fontSize: 14.0),
                            ),
                          );
                        } else {
                          return SizedBox.shrink(); // Return an empty widget if payment is complete
                        }
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PropertyDetailsScreen(property: property),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ),
                    Row(
                      children: [
                        PersistentShoppingCart()
                            .showAndUpdateCartItemWidget(
                          inCartWidget: Container(
                            height: 40,
                            width: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.indigo),
                            ),
                            child: Center(
                              child: Text(
                                'Remove',
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .bodySmall,
                              ),
                            ),
                          ),
                          notInCartWidget: Container(
                            height: 40,
                            width: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5),
                              child: Center(
                                child: Text(
                                  'Add to cart',
                                  style:
                                  Theme
                                      .of(context)
                                      .textTheme
                                      .bodySmall,
                                ),
                              ),
                            ),
                          ),
                          product: PersistentShoppingCartItem(
                            productId: property['email'],
                            productName: property['property'],
                            productDescription: property['propertyId'],
                            quantity: 1,
                            unitPrice: double.tryParse(property["price"].toString()) ?? 0.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}