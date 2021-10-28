import 'package:flutter/material.dart';
import '../component/common_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'TOMODOKO',
                  style: TextStyle(
                    fontSize: 54.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                    fontFamily: 'FjallaOne',
                    letterSpacing: 3.0,
                  ),
                ),
                const SizedBox(height: 30),
                Image.asset(
                  'images/tomodoko_top.png',
                ),
                const SizedBox(
                  height: 60.0,
                ),
                CommonButton(
                  name: 'アカウント登録',
                  onPressed: () {},
                  textColor: Colors.purple,
                  backgroundColor: Colors.white,
                ),
                CommonButton(
                  name: 'ログイン',
                  onPressed: () {},
                  textColor: Colors.white,
                  backgroundColor: Colors.purple,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
