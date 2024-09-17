import 'package:flutter/material.dart';
import 'package:fyp/constants.dart';
import 'package:fyp/src/view/screens/listing/type.dart';

class PropertyOptionsPage extends StatelessWidget {
  const PropertyOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          // Top image with bottom curve
          ClipPath(
            clipper: BottomCurveClipper(),
            child: Image.asset(
              'assets/images/buil.jpg', // Replace with your image asset
              width: double.infinity,
              height: 200.0,
              fit: BoxFit.cover,
            ),
          ),

          Center(
            child: Column(
              children: [
                const SizedBox(height: 200.0),
                Row(
                  children: [
                    Text(
                      'What are you intrested in ?',
                      style: TextStyle(
                        color: Constants.blackColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                const Reuseablebutton( property: 'Sell Property',),
                const SizedBox(height: 20.0),
                const Reuseablebutton( property: 'Rent Property',),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Reuseablebutton extends StatelessWidget {
  final String property;
  const Reuseablebutton({
    super.key,
    required this.property,
  });
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    Type(  property: property,))); // Handle give on rent button press
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.indigo, backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
          side: const BorderSide(color: Colors.indigo, width: 2.0),
        ),
        elevation: 0, // Remove shadow
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text( property ,
          style: const TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
