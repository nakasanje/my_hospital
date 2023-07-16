import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hospital_management_system/firebase_options.dart';
import 'package:hospital_management_system/screens/Dashboard.dart';
import 'package:hospital_management_system/screens/LoginPage.dart';
import 'package:hospital_management_system/screens/SignUp.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.pink,
          primaryColor: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Poppins'),
      home: SignUp(),
      debugShowCheckedModeBanner: false,
      routes: {
        SignUp.routeName: (context) => SignUp(),
        LoginPage.routeName: (context) => LoginPage(),
        Dashboard.routeName: (context) => Dashboard(
              name: 'widget.name',
              userId: 'widget.user_id',
            ),
      },
    );
  }
}
