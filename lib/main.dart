import 'package:flutter/material.dart';
import 'package:fyp/src/provider/Favourite_Provider.dart';
import 'package:fyp/src/view/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:persistent_shopping_cart/persistent_shopping_cart.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter_stripe/flutter_stripe.dart";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey='pk_test_51OghVGJKM7tbgReCU1dHECP2ci2UgORwGgFKMkD9iDYMug9zHYk077RwdLI7BZghMNFeCuKgKCBzpdZ1VCJaDn4U00foNz7GFN';

  await PersistentShoppingCart().init();
  await Firebase.initializeApp();

  // Load shared preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    ChangeNotifierProvider(
      create: (_) => PropertyProvider(savedBookmarks: prefs.getStringList('bookmarks') ?? []),
      child: MaterialApp(
        home: MyApp(),
      ),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen(),
    );
  }
}