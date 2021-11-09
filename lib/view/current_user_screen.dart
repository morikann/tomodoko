import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class CurrentUserScreen extends StatefulWidget {
  const CurrentUserScreen({Key? key}) : super(key: key);

  @override
  _CurrentUserScreenState createState() => _CurrentUserScreenState();
}

class _CurrentUserScreenState extends State<CurrentUserScreen> {
  final _auth = FirebaseAuth.instance;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _showSpinner = false;

  Future<void> getImageFromCamera() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    } else {
      print('no camera image selected');
    }
  }

  Future<void> getImageFromGallery() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    } else {
      print('no gallery image selected');
    }
  }

  Future saveImage() async {
    // 画像が選択されていなかったら早期リターン
    if (_imageFile == null) {
      return;
    }
    final String _uid = _auth.currentUser!.uid;

    // storageにアップロード
    final uploadTask =
        await FirebaseStorage.instance.ref('users/$_uid').putFile(_imageFile!);

    // storageに保存した画像のURLを取得
    final imgURL = await uploadTask.ref.getDownloadURL();

    // 保存した画像パスをfireStoreに追加
    await FirebaseFirestore.instance.collection('users').doc(_uid).update({
      'imgURL': imgURL,
    });
  }

  ImageProvider _imageProvider(String imgPath) {
    // 画像の選択があったら表示
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    }

    // cloud_storageに画像があったら表示
    if (imgPath.isNotEmpty) {
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
        inAsyncCall: _showSpinner,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                      return CircleAvatar(
                        backgroundColor: Colors.purple,
                        radius: 120,
                        child: CircleAvatar(
                          backgroundImage: _imageProvider(data['imgURL']),
                          radius: 118,
                          backgroundColor: Colors.white,
                        ),
                      );
                    }

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
                const SizedBox(height: 30),
                const Text(
                  '森 寛太',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      shape: const CircleBorder(
                        side: BorderSide(
                          color: Colors.purple,
                        ),
                      ),
                      tooltip: '写真を撮る',
                      backgroundColor: Colors.white,
                      onPressed: getImageFromCamera,
                      child: const Icon(
                        Icons.add_a_photo,
                        color: Colors.purple,
                      ),
                    ),
                    FloatingActionButton(
                      shape: const CircleBorder(
                        side: BorderSide(
                          color: Colors.purple,
                        ),
                      ),
                      tooltip: '画像を選択',
                      backgroundColor: Colors.white,
                      onPressed: getImageFromGallery,
                      child: const Icon(
                        Icons.image,
                        color: Colors.purple,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      setState(() {
                        _showSpinner = true;
                      });
                      await saveImage();

                      if (_imageFile == null) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('画像を保存しました'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('予期せぬエラーが発生しました: $e'),
                        ),
                      );
                    } finally {
                      setState(() {
                        _showSpinner = false;
                      });
                    }
                  },
                  child: const Text('保存'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
