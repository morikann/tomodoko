import 'package:flutter/material.dart';
import 'package:tomodoko/view/home_screen.dart';
import '../component/common_button.dart';
import 'signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:email_validator/email_validator.dart';
import '../component/required_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showSpinner = false;
  final _auth = FirebaseAuth.instance;
  late String email = '';
  late String password = '';

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.of(context).pushNamedAndRemoveUntil(
        HomeScreen.id,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('メールアドレスが見つかりませんでした'),
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('パスワードが正しくありません'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('予期せぬエラーが発生しました: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
              child: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Hero(
                          tag: 'logo',
                          child: SizedBox(
                            child: Image.asset('images/tomodoko_top.png'),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Expanded(
                        flex: 3,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              RequiredTextFormField(
                                controller: _emailController,
                                label: 'メールアドレス',
                                inputType: TextInputType.emailAddress,
                                validator: (value) {
                                  // 1文字以上必要
                                  if (value == null || value.isEmpty) {
                                    return 'メールアドレスを入力してください';
                                  }
                                  // メールアドレス以外は受けつけない
                                  if (!EmailValidator.validate(value)) {
                                    return '正しいメールアドレスを入力してください';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  setState(() {
                                    email = value!;
                                  });
                                },
                              ),
                              RequiredTextFormField(
                                controller: _passwordController,
                                label: 'パスワード',
                                obscure: true,
                                validator: (value) {
                                  if (!RegExp(
                                          r'^(?=.*?[a-zA-Z])(?=.*?\d)[a-zA-Z\d]{8,}$')
                                      .hasMatch(value!)) {
                                    return '8文字以上の半角英数字の混在で入力してください';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  setState(() {
                                    password = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 30),
                              CommonButton(
                                name: 'ログイン',
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      _showSpinner = true;
                                    });
                                    _formKey.currentState!.save();
                                    await signIn(email, password);
                                    setState(() {
                                      _showSpinner = false;
                                    });
                                  }
                                },
                                backgroundColor: Colors.blue,
                                textColor: Colors.white,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushNamed(SignupScreen.id);
                                  },
                                  child: const Text(
                                    'アカウント登録はこちら',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
