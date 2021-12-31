import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                    return const Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.done) {
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
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
              const SizedBox(
                height: 80,
              ),
              SizedBox(
                width: 150,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    primary: Colors.blue,
                  ),
                  onPressed: () {},
                  child: const Text(
                    '友だち申請する',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
