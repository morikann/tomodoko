import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final String name;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  const CommonButton({
    Key? key,
    required this.name,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          primary: backgroundColor,
          side: BorderSide(
            color: textColor == Colors.white ? Colors.transparent : textColor,
          ),
        ),
        onPressed: onPressed,
        child: Text(
          name,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
