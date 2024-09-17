import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class YourWidget extends StatelessWidget {
  final TextEditingController areanamecontroller = TextEditingController();
  final TextEditingController citynamecontroller = TextEditingController();



  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: w * 0.35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Color(0xFF2E5A88),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                spreadRadius: 7,
                offset: const Offset(1, 1),
                color: Colors.grey.withOpacity(0.2),
              ),
            ],
          ),
          child: TextFormField(
            textCapitalization: TextCapitalization.characters, // Capitalize all input
            inputFormatters: [
              LengthLimitingTextInputFormatter(12),
              UpperCaseTextInputFormatter(), // Apply the custom formatter
            ],
            validator: (value) {
              if (value!.isEmpty) {
                return 'Enter specific area';
              } else if (value != value.toUpperCase()) {
                return 'Enter in uppercase letters only';
              } else {
                return null;
              }
            },
            controller: areanamecontroller,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Specific area',
              hintStyle: TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Container(
          width: w * 0.36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Color(0xFF2E5A88),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                spreadRadius: 7,
                offset: const Offset(1, 1),
                color: Colors.grey.withOpacity(0.2),
              ),
            ],
          ),
          child: TextFormField(
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              LengthLimitingTextInputFormatter(18),
              UpperCaseTextInputFormatter(),
            ],
            validator: (value) {
              if (value!.isEmpty) {
                return 'Enter city name';
              } else if (value != value.toUpperCase()) {
                return 'Enter in uppercase letters only';
              } else {
                return null;
              }
            },
            controller: citynamecontroller,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'City name',
              hintStyle: TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class UpperCaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Convert input to uppercase
    final newText = newValue.text.toUpperCase();
    // Return the updated text
    return newValue.copyWith(
      text: newText,
      selection: newValue.selection,
    );
  }
}
