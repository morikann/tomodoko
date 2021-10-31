import 'package:flutter/material.dart';
import 'package:tomodoko/view/user_list_screen.dart';
import '../component/common_button.dart';
import '../component/common_text_field.dart';
import 'signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
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
        padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: Hero(
                tag: 'logo',
                child: SizedBox(
                  child: Image.asset('images/tomodoko_top.png'),
                  height: 200,
                ),
              ),
            ),
            const SizedBox(
              height: 40,
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
              onPressed: () async {
                try {
                  await _auth.signInWithEmailAndPassword(
                      email: email, password: password);
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    UserListScreen.id,
                    (route) => false,
                  );
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found') {
                    print('No user found for that email.');
                  } else if (e.code == 'wrong-password') {
                    print('Wrong password provided for that user.');
                  }
                } catch (e) {
                  print(e);
                }
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
