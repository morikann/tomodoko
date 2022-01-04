import 'package:flutter/material.dart';
import 'package:tomodoko/component/common_button.dart';
import 'login_screen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:email_validator/email_validator.dart';
import '../component/required_text_form_field.dart';
import '../services/firestore.dart';

class SignupScreen extends StatefulWidget {
  static const String id = 'signup_screen';
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _showSpinner = false;
  late String username = '';
  late String email = '';
  late String password = '';
  final _firestore = Firestore();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // widgetTreeからwidgetが消された時に、controllerも綺麗に消す
    _nameController.dispose();
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
          'アカウント登録',
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
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 30),
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
                              // username field
                              RequiredTextFormField(
                                controller: _nameController,
                                label: 'ユーザー名',
                                inputType: TextInputType.name,
                                validator: (value) {
                                  // 1文字以上10文字以内（スペースなどの空白で通ってしまうので、trimメソッドで前後の空白を消す）
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      value.length > 10) {
                                    return '1~10文字以内で名前を入力してください';
                                  }
                                  // 同じ名前は登録できない
                                  if (_firestore.nameExists) {
                                    return '名前は既に存在しています';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  setState(() {
                                    username = value!;
                                    username = username.trim();
                                  });
                                },
                              ),
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
                              const SizedBox(
                                height: 30,
                              ),
                              CommonButton(
                                  name: '登録',
                                  textColor: Colors.white,
                                  backgroundColor: Colors.blue,
                                  onPressed: () async {
                                    _formKey.currentState!.save();
                                    await _firestore.checkNameExists(username);
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        _showSpinner = true;
                                      });
                                      // await signup(email, password);
                                      String? uid = await _firestore.signup(
                                          email, password, context);
                                      if (uid != null) {
                                        await _firestore.saveUser(
                                            uid, username, email, context);
                                        setState(() {
                                          _showSpinner = false;
                                        });
                                      } else {
                                        setState(() {
                                          _showSpinner = false;
                                        });
                                      }
                                    }
                                  }),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushNamed(LoginScreen.id);
                                  },
                                  child: const Text(
                                    'ログインはこちら',
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
