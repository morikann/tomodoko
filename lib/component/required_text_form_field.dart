import 'package:flutter/material.dart';

class RequiredTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final void Function(String?) onSaved;
  final TextInputType? inputType;
  final bool obscure;

  const RequiredTextFormField({
    Key? key,
    required this.controller,
    required this.label,
    required this.validator,
    required this.onSaved,
    this.inputType,
    this.obscure = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscure,
      keyboardType: inputType,
      validator: validator,
      onSaved: onSaved,
      controller: controller,
      decoration: InputDecoration(
        label: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Colors.black,
            ),
            children: [
              TextSpan(text: label),
              const TextSpan(
                text: '*',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
