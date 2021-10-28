import 'package:flutter/material.dart';
import './view/home_screen.dart';

void main() {
  runApp(const Tomodoko());
}

class Tomodoko extends StatelessWidget {
  const Tomodoko({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tomodoko',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
