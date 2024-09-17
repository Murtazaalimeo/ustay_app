// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print, library_private_types_in_public_api

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

import '../view/screens/bottomnavigator.dart';

class Payment extends StatefulWidget {
  final double totalAmount;
  final String propertyId; // Add propertyId parameter
  final String productName;
  final String productDescription;

  const Payment({
    Key? key,
    required this.totalAmount,
    required this.propertyId,
    required this.productName,
    required this.productDescription,
  }) : super(key: key);

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  Map<String, dynamic>? paymentIntentData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BottomTabNav(),
              ),
            );
          },
        ),
      ),
      backgroundColor: Colors.deepPurple[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Total Amount: \$${widget.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  await makePayment();
                },
                child: Container(
                  height: 50,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Pay',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      paymentIntentData =
      await createPaymentIntent(widget.totalAmount.toString(), 'USD');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: 'Your Secret Key',
          paymentIntentClientSecret: paymentIntentData!['client_secret'],
          customFlow: true,
          style: ThemeMode.dark,
          merchantDisplayName: 'Your Merchant Name',
        ),
      );
      displayPaymentSheet();
    } catch (e, s) {
      print('Payment exception:$e$s');
    }
  }

  displayPaymentSheet() async {
    try {
      await _updatePaymentStatusInFirestore();
      await Stripe.instance.presentPaymentSheet().then((newValue) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Paid successfully")));

        paymentIntentData = null;
      }).onError((error, stackTrace) {
        print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Exception/DISPLAYPAYMENTSHEET==> $e');
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Text("Cancelled"),
        ),
      );
    } catch (e) {
      print('$e');
    }
  }

  Future<void> _updatePaymentStatusInFirestore() async {
    try {
      // Query for the document with the matching propertyId
      var snapshot = await FirebaseFirestore.instance
          .collection('properties')
          .doc(widget.productDescription)
          .get();

      if (snapshot.exists) {
        // Update the payment status and additional data
        await snapshot.reference.set({
          'paymentComplete': true,
          'productName': widget.productName,
          'productDescription': widget.productDescription,
          'amountPaid': widget.totalAmount,
          'paymentTimestamp': FieldValue.serverTimestamp(),
          'userId': FirebaseAuth.instance.currentUser!.uid,
        }, SetOptions(merge: true));
      } else {
        print('No matching property document found.');
      }
    } catch (e) {
      print('Firestore error: $e');
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization':
          'Bearer ',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to create payment intent: ${response.body}');
        return Future.error('Failed to create payment intent');
      }
    } catch (err) {
      print('Error charging user: ${err.toString()}');
      return Future.error('Error charging user');
    }
  }

  String calculateAmount(String amount) {
    final a = (double.parse(amount) * 100).toInt();
    return a.toString();
  }
}
