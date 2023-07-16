import 'package:flutter/material.dart';
import 'package:hospital_management_system/screens/Dashboard.dart';
import 'package:hospital_management_system/screens/LoginPage.dart';
import 'package:hospital_management_system/screens/SignUp.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case Dashboard.routeName:
      return MaterialPageRoute(
        builder: (_) => Dashboard(
          name: 'name',
          userId: 'user_id',
        ),
      );

    case LoginPage.routeName:
      return MaterialPageRoute(
        builder: (_) => LoginPage(),
      );

    case SignUp.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => SignUp(),
      );

    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(),
      );
  }
}
