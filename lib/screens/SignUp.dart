import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:hospital_management_system/constants/images.dart';

import 'package:hospital_management_system/screens/LoginPage.dart';

import 'package:hospital_management_system/widgets/MyTextField.dart';

import '../constants/custom_button.dart';
import '../constants/global_variables.dart';
import '../constants/space.dart';
import '../firebase_options.dart';

class SignUp extends StatefulWidget {
  static const routeName = "/signup";
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late double width;
  late double height;
  bool visible = false;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _contactController = TextEditingController();

  TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future signUp() async {
    try {
      if (_formKey.currentState!.validate()) {
        showDialog(
            context: context,
            builder: (context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            });

        final email = _emailController.text;
        final password = _passwordController.text;

        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        Fluttertoast.showToast(
          msg: "Account created Successfully",
          gravity: ToastGravity.CENTER,
          backgroundColor: GlobalVariables.primaryColor,
        );

        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, LoginPage.routeName);
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: "${e.message}",
        gravity: ToastGravity.CENTER,
        backgroundColor: Color.fromARGB(255, 230, 92, 193),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 18, right: 18),
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
                            const SizedBox(height: 20),
                            SvgPicture.asset(
                              login_image,
                              height: width * 0.20,
                            ),
                            const SizedBox(height: 20),
                            MyTextField(
                              hint: 'name',
                              icon: Icons.person,
                              validation: (value) {
                                if (value!.isEmpty) {
                                  return "Enter your name";
                                }
                                return null;
                              },
                              controller: _nameController,
                            ),
                            const Space(),
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
                                  hint: 'Password',
                                  isPassword: true,
                                  isSecure: true,
                                  icon: Icons.password,
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
                            StatefulBuilder(
                              builder: (context, setState) {
                                return MyTextField(
                                  hint: 'Contact',
                                  isNumber: true,
                                  icon: Icons.contact_page,
                                  validation: (value) {
                                    if (value!.isEmpty) {
                                      return "please Enter Your Contact";
                                    }
                                    if (value.length < 10) {
                                      return "contact is Short";
                                    }

                                    return null;
                                  },
                                  controller: _contactController,
                                );
                              },
                            ),
                            const Space(),
                            CustomButton(
                              onTap: signUp,
                              label: "Sign Up",
                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(
                                  context, LoginPage.routeName),
                              child: const Text("Already Have an Account"),
                            )
                          ],
                        ),
                      );
                    default:
                      return const Text("Loading");
                  }
                }),
          ),
        ),
      ),
    );
  }
}
