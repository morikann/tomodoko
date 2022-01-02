import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:tomodoko/view/home_screen.dart';

class FriendRequestScreen extends StatefulWidget {
  static const id = 'friend_request_screen';
  final String friendUid;
  const FriendRequestScreen({
    Key? key,
    required this.friendUid,
  }) : super(key: key);

  @override
  _FriendRequestScreenState createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  File? _imageFile;
  bool? isFollow;

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

  void _friendRequest() async {
    await FirebaseFirestore.instance
        .collection('follows')
        .add({
          'following_uid': FirebaseAuth.instance.currentUser?.uid,
          'followed_uid': widget.friendUid,
        })
        .then((value) => print('save user'))
        .catchError((e) => print(e));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
            HomeScreen.id,
            (route) => false,
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.cancel_outlined,
          size: 42,
          color: Colors.grey,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          '友だち追加',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.friendUid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('予期せぬエラーが発生しました');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  Map<String, dynamic> data =
                      snapshot.data?.data() as Map<String, dynamic>;
                  return Column(
                    children: [
                      const SizedBox(height: 80),
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 80,
                        child: CircleAvatar(
                          backgroundImage: _imageProvider(data['imgURL']),
                          radius: 78,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        data['name'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(
                height: 80,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('follows')
                    .where('following_uid',
                        isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .where('followed_uid', isEqualTo: widget.friendUid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('予期せぬエラーが発生しました');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  isFollow = snapshot.data?.docs.isNotEmpty;

                  return SizedBox(
                    width: 150,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        primary: isFollow! ? Colors.grey.shade200 : Colors.blue,
                      ),
                      onPressed: isFollow! ? null : _friendRequest,
                      child: Text(
                        isFollow! ? '友だち申請済み' : '友だち申請する',
                        style: TextStyle(
                          color:
                              isFollow! ? Colors.grey.shade800 : Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
