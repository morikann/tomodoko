import 'package:flutter/material.dart';
import '../component/common_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late String username;
  late String email;
  late String password;

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
                name: 'ユーザー名',
                onChanged: (value) {
                  username = value;
                },
              ),
              CommonTextField(
                name: 'メールアドレス',
                onChanged: (value) {
                  email = value;
                },
              ),
              CommonTextField(
                name: 'パスワード',
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
                },
                backgroundColor: Colors.purple,
                textColor: Colors.white,
              ),
              TextButton(
                onPressed: () {},
                child: const Text('ログインはこちら'),
              ),
            ],
          ),
        ));
  }
}

class CommonTextField extends StatelessWidget {
  final String name;
  final bool? obscure;
  final Function(String) onChanged;

  const CommonTextField({
    required this.name,
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
          name,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
