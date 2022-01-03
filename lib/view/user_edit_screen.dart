import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../model/image_manager.dart';

class UserEditScreen extends StatefulWidget {
  static const String id = 'user_edit_screen';
  const UserEditScreen({Key? key}) : super(key: key);

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  bool showSpinner = false;
  bool _nameExists = false;
  String inputUsername = '';
  String currentUsername = '';
  bool hasUpdated = false;
  final imageManager = ImageManager();

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future updateProfile() async {
    final String _uid = _auth.currentUser!.uid;
    // 名前の変更あり かつ 画像の変更あり
    if (inputUsername != currentUsername && imageManager.imageFile != null) {
      // storageにアップロード
      final uploadTask = await FirebaseStorage.instance
          .ref('users/$_uid')
          .putFile(imageManager.imageFile!);

      // storageに保存した画像のURLを取得
      final imgURL = await uploadTask.ref.getDownloadURL();

      // 名前、画像を更新
      await FirebaseFirestore.instance.collection('users').doc(_uid).update({
        'imgURL': imgURL,
        'name': inputUsername,
      });

      hasUpdated = true;

      // 名前の変更のみあり
    } else if (inputUsername != currentUsername) {
      // 名前を更新
      await FirebaseFirestore.instance.collection('users').doc(_uid).update({
        'name': inputUsername,
      });

      hasUpdated = true;

      // 画像の変更のみあり
    } else if (imageManager.imageFile != null) {
      // storageにアップロード
      final uploadTask = await FirebaseStorage.instance
          .ref('users/$_uid')
          .putFile(imageManager.imageFile!);

      // storageに保存した画像のURLを取得
      final imgURL = await uploadTask.ref.getDownloadURL();

      // 画像を更新
      await FirebaseFirestore.instance.collection('users').doc(_uid).update({
        'imgURL': imgURL,
      });

      hasUpdated = true;
    } else {
      // 何も変更がなかった際にboolを更新
      hasUpdated = false;
    }
  }

  Future<void> checkNameExists(String name) async {
    await _fireStore
        .collection('users')
        .where('name', isEqualTo: name)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        _nameExists = true;
      } else {
        _nameExists = false;
      }
    }).catchError((e) {
      _nameExists = false;
    });
  }

  Future<void> updateSequence() async {
    try {
      setState(() {
        showSpinner = true;
      });
      await updateProfile();

      // 何も更新がなかったら早期リターン
      if (!hasUpdated) {
        return;
      }

      Navigator.of(_scaffoldKey.currentContext!).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('プロフィールを更新しました'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('予期せぬエラーが発生しました: $e'),
        ),
      );
    } finally {
      setState(() {
        showSpinner = false;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'プロフィールの編集',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 50, right: 30, left: 30),
            child: SingleChildScrollView(
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

                        currentUsername = data['name'] ?? '';
                        // 初期値を入れる
                        _nameController =
                            TextEditingController(text: currentUsername);

                        return Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue,
                              radius: 80,
                              child: CircleAvatar(
                                backgroundImage: imageManager
                                    .getImageProvider(data['imgURL']),
                                radius: 78,
                                backgroundColor: Colors.white,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      child: CircleAvatar(
                                        child: CircleAvatar(
                                          child: IconButton(
                                            onPressed: () {
                                              showModalBottomSheet(
                                                context: context,
                                                builder: buildBottomSheet,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                    top: Radius.circular(16),
                                                  ),
                                                ),
                                                isScrollControlled: true,
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.photo_camera,
                                              color: Colors.black,
                                              size: 22,
                                            ),
                                          ),
                                          backgroundColor: Colors.grey.shade300,
                                          radius: 20,
                                        ),
                                        radius: 22,
                                        backgroundColor: Colors.white,
                                      ),
                                      bottom: 0,
                                      right: 0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      label: const Text('ユーザー名'),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding: const EdgeInsets.all(20),
                                    ),
                                    // initialValue: data['name'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
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
                                    onSaved: (value) {
                                      inputUsername = value!;
                                    },
                                  ),
                                ],
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
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        _formKey.currentState!.save();
                        // 名前の変更がなかったらvalidationを通さない
                        if (inputUsername == currentUsername) {
                          await updateSequence();
                        } else {
                          await checkNameExists(inputUsername);
                          if (_formKey.currentState!.validate()) {
                            await updateSequence();
                          }
                        }
                      },
                      child: const Text('保存'),
                    ),
                  ),
                ],
              ),
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
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: const Icon(
                Icons.add_a_photo,
                color: Colors.black,
              ),
            ),
            title: const Text(
              'プロフォール写真を撮る',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              await imageManager.getImageFromCamera();
              setState(() {});
              if (imageManager.isFileSelected) {
                Navigator.of(context).pop();
              }
            },
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: const Icon(
                Icons.image,
                color: Colors.black,
              ),
            ),
            title: const Text(
              'プロフィール写真を選択',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              await imageManager.getImageFromGallery();
              setState(() {});
              if (imageManager.isFileSelected) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
