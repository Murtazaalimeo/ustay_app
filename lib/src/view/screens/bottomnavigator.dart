import 'package:flutter/material.dart';
import 'package:fyp/src/view/screens/listing/display.dart';
import 'package:fyp/src/view/screens/profile_screen.dart';
import 'package:fyp/src/view/screens/saved.dart';
import 'package:fyp/src/view/screens/map.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';


import 'options.dart';


class BottomTabNav extends StatefulWidget {
  const BottomTabNav({super.key});

  @override
  _BottomTabNavState createState() => _BottomTabNavState();
}

class _BottomTabNavState extends State<BottomTabNav> {
  int _selectedIndex = 0;
  static  List<Widget> _widgetOptions = <Widget>[
    Display(),
    FavoritePlacesScreen(),
    MapScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(

      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D001A),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.01,
              vertical: screenWidth * 0.03  ,
            ),
            child: GNav(
              rippleColor: Colors.grey,
              hoverColor: Colors.blueGrey,
              gap: 8,
              activeColor: Colors.white70,
              iconSize: screenWidth * 0.06, // Adjust icon size
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.040,
                vertical: screenWidth * 0.05,
              ),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.indigo,
              color: Colors.white70,
              tabs: const [
                GButton(
                  icon: LineIcons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: LineIcons.heart,
                  text: 'Saved',
                ),
                GButton(
                  icon: LineIcons.mapMarker,
                  text: 'Map',
                ),
                GButton(
                  icon: LineIcons.user,
                  text: 'Profile',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
