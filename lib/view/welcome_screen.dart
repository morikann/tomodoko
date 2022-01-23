import 'package:flutter/material.dart';
import '../component/common_button.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const String id = 'welcome_screen';
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: FittedBox(
                      child: Text(
                        'TOMODOKO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontFamily: 'FjallaOne',
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Hero(
                    tag: 'logo',
                    child: SizedBox(
                      height: 250,
                      child: Image.asset(
                        'images/tomodoko_top.png',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 60.0,
                  ),
                  CommonButton(
                    name: 'アカウント登録',
                    onPressed: () {
                      Navigator.of(context).pushNamed(SignupScreen.id);
                    },
                    textColor: Colors.blue,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CommonButton(
                    name: 'ログイン',
                    onPressed: () {
                      Navigator.of(context).pushNamed(LoginScreen.id);
                    },
                    textColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
