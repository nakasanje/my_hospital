import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'custom_textfield.dart';
import 'global_variables.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController emailController = TextEditingController();

  Future passwordRest() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      Fluttertoast.showToast(
        msg: "Password reset link sent! Check your email!",
        gravity: ToastGravity.CENTER,
        backgroundColor: GlobalVariables.primaryColor,
      );
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: "${e.message}",
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red[800],
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 23),
            child: Text(
              "Enter your email and we will send you a Password reset Link",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: MyTextField(
              label: "Email",
              controller: emailController,
              inputType: TextInputType.emailAddress,
              obscure: false,
            ),
          ),
          const SizedBox(height: 20),
          MaterialButton(
            onPressed: () => passwordRest(),
            color: GlobalVariables.primaryColor,
            child: const Text(
              "Reset Password",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
