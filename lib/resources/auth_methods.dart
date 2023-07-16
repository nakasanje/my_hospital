import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  signUpUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {} catch (e) {
      if (email.isNotEmpty || password.isNotEmpty || name.isNotEmpty) {
        //registering user
        UserCredential credentials = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        //storing user to database
        await _firestore.collection("users").doc(credentials.user!.uid).set({
          "name": name,
          "uid": credentials.user!.uid,
        });
      }
    }
  }
}
