
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp/src/utils/routes/routes_names.dart';
import 'package:fyp/src/view/screens/bottomnavigator.dart';
import 'package:fyp/src/view/screens/options.dart';



class Routes {

  static Route<dynamic> generateRoute(RouteSettings settings){

    switch(settings.name){
      case RoutesName.option:
        return MaterialPageRoute(builder: (BuildContext context) => RentOptionsScreen());
      case RoutesName.home:
        return MaterialPageRoute(builder: (BuildContext context) => BottomTabNav());

      default :
        return MaterialPageRoute(builder: (_){
          return Scaffold(
            body: Center(
              child: Text('No Route Defined'),
            ),
          );
        });
    }
  }
}