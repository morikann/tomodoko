import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_edit_screen.dart';
import 'welcome_screen.dart';
import 'dart:io';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class CurrentUserScreen extends StatefulWidget {
  const CurrentUserScreen({Key? key}) : super(key: key);

  @override
  _CurrentUserScreenState createState() => _CurrentUserScreenState();
}

class _CurrentUserScreenState extends State<CurrentUserScreen> {
  final _auth = FirebaseAuth.instance;
  File? _imageFile;
  bool showSpinner = false;

  ImageProvider _imageProvider(imgPath) {
    // 画像の選択があったら表示
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    }

    // cloud_storageに画像があったら表示
    if (imgPath != null) {
      return NetworkImage(imgPath);
    }

    // 何もなかったらデフォルト画像
    return const AssetImage('images/default.png');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'マイページ',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await showDialog<AlertDialog>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('ログアウトしますか？'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _auth.signOut();
                          Navigator.of(context)
                              .pushReplacementNamed(WelcomeScreen.id);
                        },
                        child: const Text('OK'),
                      )
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 50, right: 30, left: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(_auth.currentUser!.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      Map<String, dynamic> data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      return Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 120,
                            child: CircleAvatar(
                              backgroundImage: _imageProvider(data['imgURL']),
                              radius: 118,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            data['name'] ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ],
                      );
                    }

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  height: 45,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: const BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(UserEditScreen.id).then(
                            (_) => setState(() {}),
                          ); // 遷移先からpopした際にstateが更新されるようにするため、thenでつなぐ。
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.blue,
                    ),
                    label: const Text(
                      'プロフィールを編集',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
