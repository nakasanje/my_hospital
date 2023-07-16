import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final String label;
  final Widget? suffixIcon;
  final TextInputType inputType;
  final bool? obscure;
  final TextEditingController controller;
  final String? Function(String?)? validate;

  const MyTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.inputType,
    this.obscure,
    this.validate,
    this.suffixIcon,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.validate,
      keyboardType: widget.inputType,
      obscureText: widget.obscure!,
      controller: widget.controller,
      decoration: InputDecoration(
        suffixIcon: widget.suffixIcon,
        hintText: widget.label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(34),
          ),
        ),
      ),
    );
  }
}
