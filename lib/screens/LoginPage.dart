import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:hospital_management_system/constants/images.dart';

import 'package:hospital_management_system/screens/SignUp.dart';
import 'package:hospital_management_system/screens/Dashboard.dart';

import 'package:hospital_management_system/widgets/MyTextField.dart';

import '../constants/custom_button.dart';
import '../constants/forgot_password_screen.dart';
import '../constants/space.dart';
import '../firebase_options.dart';

class LoginPage extends StatefulWidget {
  static const routeName = "/loginpage";
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late double width;
  late double height;
  bool visible = false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool loading = false;
  String error = "";

  Future signIn() async {
    try {
      if (_formKey.currentState!.validate()) {
        setState(() {
          loading = true;
        });
        final email = _emailController.text;
        final password = _passwordController.text;
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Dashboard(
              name: 'widget.name',
              userId: 'widget.user_id',
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: "${e.message}",
        gravity: ToastGravity.CENTER,
        backgroundColor: Color.fromARGB(255, 132, 63, 128),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 18, right: 18, top: 60),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: FutureBuilder(
                future: Firebase.initializeApp(
                  options: DefaultFirebaseOptions.currentPlatform,
                ),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );

                    case ConnectionState.done:
                      return Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const Space(),
                            SvgPicture.asset(
                              login_image,
                              height: width * 0.20,
                            ),
                            const SizedBox(height: 30),
                            MyTextField(
                              hint: "Email",
                              isEmail: true,
                              icon: Icons.contact_mail,
                              validation: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter an Email";
                                }
                                if (!RegExp(
                                        "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                    .hasMatch(value)) {
                                  return "Invalid Email !";
                                }
                                return null;
                              },
                              controller: _emailController,
                            ),
                            const Space(),
                            StatefulBuilder(
                              builder: (context, setState) {
                                return MyTextField(
                                  hint: 'password',
                                  isPassword: true,
                                  isSecure: true,
                                  icon: Icons.account_balance_sharp,
                                  validation: (value) {
                                    if (value!.isEmpty) {
                                      return "Please enter Password";
                                    }
                                    if (value.length < 6) {
                                      return "Password is Short";
                                    }
                                    return null;
                                  },
                                  controller: _passwordController,
                                );
                              },
                            ),
                            const Space(),
                            CustomButton(
                              onTap: signIn,
                              label: "Login",
                            ),
                            const SizedBox(height: 30),
                            Wrap(
                              spacing: 20,
                              direction: Axis.horizontal,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                      context, SignUp.routeName),
                                  child: const Text("Create an Account"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ForgotPasswordPage(),
                                    ),
                                  ),
                                  child: const Text("Forgot Password !"),
                                ),
                              ],
                            )
                          ],
                        ),
                      );

                    default:
                      return const Text("Loading.......");
                  }
                }),
          ),
        ),
      ),
    );
  }
}
