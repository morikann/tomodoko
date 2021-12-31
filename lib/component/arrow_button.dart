import 'package:flutter/material.dart';

class ArrowButton extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;

  const ArrowButton({
    Key? key,
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        primary: backgroundColor,
      ),
      onPressed: onPressed,
      child: Icon(
        icon,
        color: iconColor,
      ),
    );
  }
}
