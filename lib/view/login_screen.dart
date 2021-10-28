import 'package:flutter/material.dart';
import '../component/common_button.dart';
import '../component/common_text_field.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String email = '';
  late String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'ログイン',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'logo',
              child: SizedBox(
                child: Image.asset('images/tomodoko_top.png'),
                height: 250,
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            CommonTextField(
              label: 'メールアドレス',
              onChanged: (value) {
                email = value;
              },
            ),
            CommonTextField(
              label: 'パスワード',
              obscure: true,
              onChanged: (value) {
                password = value;
              },
            ),
            const SizedBox(height: 30),
            CommonButton(
              name: 'ログイン',
              onPressed: () {
                print(email);
                print(password);
              },
              backgroundColor: Colors.purple,
              textColor: Colors.white,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(SignupScreen.id);
              },
              child: const Text('アカウント登録はこちら'),
            ),
          ],
        ),
      ),
    );
  }
}
