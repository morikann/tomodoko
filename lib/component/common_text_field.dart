import 'package:flutter/material.dart';

class CommonTextField extends StatelessWidget {
  final String label;
  final bool? obscure;
  final Function(String) onChanged;

  const CommonTextField({
    required this.label,
    this.obscure,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      obscureText: obscure ?? false,
      decoration: InputDecoration(
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
