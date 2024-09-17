import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:fyp/src/view/screens/bottomnavigator.dart';

class PriceRangeSelectionScreen extends StatefulWidget {
  @override
  _PriceRangeSelectionScreenState createState() =>
      _PriceRangeSelectionScreenState();
}

class _PriceRangeSelectionScreenState
    extends State<PriceRangeSelectionScreen> {
  double _lowerValue = 1000.0;
  double _upperValue = 40000.0; // Adjust the upper limit as needed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Price Range'),
        actions: [
          // Skip option
          TextButton(
            onPressed: () {
              // Handle skip button press
              Navigator.push(context, MaterialPageRoute(builder: (_) =>BottomTabNav()));
              // Navigate to home page or any desired page
            },
            child: const Text(
              'Skip',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/images/house.jpg',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),

          // Content
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FlutterSlider(
                    values: [_lowerValue, _upperValue],
                    rangeSlider: true,
                    max: 50000, // Adjust the max value based on your desired upper limit
                    min: 500,
                    onDragging: (handlerIndex, lowerValue, upperValue) {
                      setState(() {
                        _lowerValue = lowerValue;
                        _upperValue = upperValue;
                      });
                    },
                    handler: FlutterSliderHandler(
                      decoration: const BoxDecoration(),
                    ),
                    rightHandler: FlutterSliderHandler(
                      decoration: const BoxDecoration(),
                    ),
                    trackBar: const FlutterSliderTrackBar(
                      activeTrackBar: BoxDecoration(
                        color: Colors.indigo,
                      ),
                      inactiveTrackBar: BoxDecoration(
                        color: Colors.grey,
                      ),
                    ),
                    tooltip: FlutterSliderTooltip(
                      alwaysShowTooltip: true,
                      textStyle: const TextStyle(fontSize: 17, color: Colors.black54),
                      leftPrefix: const Text('Rs', style: TextStyle(fontSize: 14)),
                      rightSuffix: const Text('Rs', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Selected Range: Rs$_lowerValue - Rs$_upperValue',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  // Next button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) =>BottomTabNav()));
                      // Handle next button press
                      // Navigate to the next screen or home page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.indigo, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                      child: Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
