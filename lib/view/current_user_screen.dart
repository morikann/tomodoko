import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tomodoko/view/friend/friend_request_list_screen.dart';
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
        centerTitle: true,
        title: const Text(
          'マイページ',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: buildBottomSheet,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                isScrollControlled: true,
              );
            },
            icon: const Icon(
              Icons.dehaze,
            ),
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 50, right: 30, left: 30, bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(_auth.currentUser?.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }

                    if (snapshot.data?.data() == null) {
                      return const Center(
                        child: Text('ログインしてください'),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      Map<String, dynamic> data =
                          snapshot.data?.data() as Map<String, dynamic>;
                      return Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade400,
                            radius: 80,
                            child: CircleAvatar(
                              backgroundImage: _imageProvider(data['imgURL']),
                              radius: 79,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            data['name'] ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
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
                  height: 60,
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

  Widget buildBottomSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 10),
          ),
          ListTile(
            leading: const Icon(
              Icons.tag_faces,
              color: Colors.black,
              size: 28,
            ),
            title: const Text('友達リクエスト'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(FriendRequestListScreen.id);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.black,
              size: 28,
            ),
            title: const Text('ログアウト'),
            onTap: () async {
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
          ),
          ListTile(
            leading: const Icon(
              Icons.warning,
              color: Colors.black,
              size: 28,
            ),
            title: const Text('退会'),
            onTap: () async {
              await showDialog<AlertDialog>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('退会'),
                    content: const Text(
                        '一度退会すると、過去のデータの全てが消去されます。この操作は元に戻すことはできません。それでも退会しますか？'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final data = {
                            'uid': _auth.currentUser?.uid,
                            'createdAt': Timestamp.now(),
                          };
                          await FirebaseFirestore.instance
                              .collection('deleted_users')
                              .add(data)
                              .then((_) async => {
                                    await _auth.signOut(),
                                    Navigator.of(context)
                                        .pushReplacementNamed(WelcomeScreen.id),
                                  })
                              .catchError(
                                  (e) => print('Failed to add user $e'));
                        },
                        child: const Text('退会する'),
                      )
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
