import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_management_system/constants/colors.dart';
import 'package:hospital_management_system/widgets/DashboardTiles.dart';

enum Page { dashboard, manage }

class Dashboard extends StatefulWidget {
  static const routeName = "/dashdoard";
  final String name;
  final String userId;

  Dashboard({required this.name, required this.userId});
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Page _selectedPage = Page.dashboard;
  late double width;
  late double height;
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: _loadScreen(_selectedPage),
        backgroundColor: backgroundColor,
      ),
    );
  }

  Widget _loadScreen(page) {
    switch (_selectedPage) {
      case Page.dashboard:
        return DashboardTiles(
          username: widget.name,
          userId: widget.userId,
        );

      case Page.manage:
        return Container(
          height: height * 0.8,
        );
      default:
        return Container();
    }
  }
}
