import 'package:flutter/material.dart';
import '../component/common_button.dart';
import '../component/common_text_field.dart';
import 'login_screen.dart';
import 'user_list_screen.dart';

class SignupScreen extends StatefulWidget {
  static const String id = 'signup_screen';
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late String username = '';
  late String email = '';
  late String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'アカウント登録',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Hero(
                tag: 'logo',
                child: Flexible(
                  child: SizedBox(
                    child: Image.asset('images/tomodoko_top.png'),
                    height: 250,
                  ),
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              CommonTextField(
                label: 'ユーザー名',
                onChanged: (value) {
                  username = value;
                },
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
                name: '登録',
                onPressed: () {
                  print(username);
                  print(email);
                  print(password);
                  Navigator.of(context).pushNamed(UserListScreen.id);
                },
                backgroundColor: Colors.purple,
                textColor: Colors.white,
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(LoginScreen.id);
                },
                child: const Text('ログインはこちら'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
