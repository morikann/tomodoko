import 'package:flutter/material.dart';
import 'package:tomodoko/component/common_button.dart';
import 'login_screen.dart';
import 'user_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:email_validator/email_validator.dart';

class SignupScreen extends StatefulWidget {
  static const String id = 'signup_screen';
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  bool _showSpinner = false;
  late String username = '';
  late String email = '';
  late String password = '';
  bool _nameExists = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> addUser(String uid) {
    return _fireStore.collection('users').doc(uid).set({
      'uid': uid,
      'name': username,
    }).then((value) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        UserListScreen.id,
        (route) => false,
      );
      setState(() {
        _showSpinner = false;
      });
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('予期せぬエラーが発生しました: $e'),
        ),
      );
      setState(() {
        _showSpinner = false;
      });
    });
  }

  Future<void> signup(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user!.uid;
      addUser(uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('$emailは既に登録されています'),
          ),
        );
        setState(() {
          _showSpinner = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('予期せぬエラーが発生しました: $e'),
        ),
      );
      setState(() {
        _showSpinner = false;
      });
    }
  }

  Future<void> checkNameExists(String name) async {
    // このコード内ではawaitがなくてもうまく動作するが、呼び出し元のonPressed()で
    // この関数を呼び出すときに以下の非同期処理をawaitしていないと、処理が先に進み
    // うまく動作しないため、awaitが必要。非同期処理は複雑だからもっと勉強しないと。
    await _fireStore
        .collection('users')
        .where('name', isEqualTo: name)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _nameExists = true;
        });
      } else {
        setState(() {
          _nameExists = false;
        });
      }
    }).catchError((e) {
      setState(() {
        _nameExists = false;
      });
    });
  }

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
                            // username field
                            TextFormField(
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                // 1文字以上10文字以内（スペースなどの空白で通ってしまうので、trimメソッドで前後の空白を消す）
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.length > 10) {
                                  return '1~10文字以内で名前を入力してください';
                                }
                                // 同じ名前は登録できない
                                if (_nameExists) {
                                  return '名前は既に存在しています';
                                }
                                return null;
                              },
                              onChanged: (value) async {
                                // validator内では非同期処理が使えないので、onChanged内でstateを更新。
                                // ただ、文字が変わるたびにクエリを発行してfireStoreに余分な負荷がかかりそう。
                                // onSaved内で書いた場合、_formKey.currentState!.save();の後に_formKey.currentState!.validate()を
                                // 実行してもcheckNameExists(value)は非同期なので、_formKey.currentState!.validate()が
                                // 先に実行されてうまく動作しない
                                // await checkNameExists(value);
                              },
                              onSaved: (value) {
                                setState(() {
                                  username = value!;
                                });
                              },
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'username',
                              ),
                            ),
                            // email field
                            emailTextField(),
                            // password field
                            passwordTextField(),
                            const SizedBox(
                              height: 30,
                            ),
                            CommonButton(
                              name: '登録',
                              textColor: Colors.white,
                              backgroundColor: Colors.purple,
                              onPressed: () async {
                                _formKey.currentState!.save();
                                await checkNameExists(username);
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _showSpinner = true;
                                  });
                                  await signup(email, password);
                                }
                              },
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField passwordTextField() {
    return TextFormField(
      obscureText: true,
      validator: (value) {
        if (!RegExp(r'^(?=.*?[a-zA-Z])(?=.*?\d)[a-zA-Z\d]{8,}$')
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
      controller: _passwordController,
      decoration: const InputDecoration(
        labelText: 'password',
      ),
    );
  }

  TextFormField emailTextField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
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
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'email',
      ),
    );
  }
}
