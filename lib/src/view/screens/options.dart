import 'package:flutter/material.dart';
import 'package:fyp/src/view/screens/listing/Porperty_listing.dart';
import 'bottomnavigator.dart';


class RentOptionsScreen extends StatelessWidget {
  const RentOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white38, // Dark grey background
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/fyp.png', // Replace with your image path
                width: 200.0, // Adjust width as needed
                height: 200.0, // Adjust height as needed
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20.0),
              const Text(
                'What are you intrested in ?',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50.0),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RentOptionButton(
                        title: 'Rent / Buy',
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const BottomTabNav()));    // Handle give on rent button press
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RentOptionButton(
                        title: 'List your Property ',
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const PropertyOptionsPage()));    // Handle give on rent button press
                        },
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RentOptionButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const RentOptionButton({super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(
          color: Colors.indigo, // Deep purple color for bottom border
          width: 2.0,
        ),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30.0),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

