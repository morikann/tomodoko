import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CurrentUserScreen extends StatefulWidget {
  const CurrentUserScreen({Key? key}) : super(key: key);

  @override
  _CurrentUserScreenState createState() => _CurrentUserScreenState();
}

class _CurrentUserScreenState extends State<CurrentUserScreen> {
  final _auth = FirebaseAuth.instance;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> getImageFromCamera() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
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
        _image = File(pickedFile.path);
      });
    } else {
      print('no gallery image selected');
    }
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CircleAvatar(
                backgroundColor: Colors.purple,
                radius: 120,
                child: CircleAvatar(
                  backgroundImage: _image == null
                      ? const AssetImage('images/default.png')
                      : FileImage(_image!) as ImageProvider,
                  radius: 118,
                  backgroundColor: Colors.white,
                ),
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
                onPressed: () {},
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
