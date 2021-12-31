import 'package:flutter/material.dart';
import 'package:tomodoko/view/friend/friend_request_screen.dart';
import '../../component/arrow_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendAddScreen extends StatefulWidget {
  static const id = 'friend_add_screen';
  const FriendAddScreen({Key? key}) : super(key: key);

  @override
  _FriendAddScreenState createState() => _FriendAddScreenState();
}

class _FriendAddScreenState extends State<FriendAddScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _nameExists = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String? friendUid;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  Future<void> checkNameExists(String name) async {
    await _firestore
        .collection('users')
        .where('name', isEqualTo: name)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        _nameExists = true;
        friendUid = querySnapshot.docs.first.id;
      } else {
        _nameExists = false;
      }
    }).catchError((e) {
      _nameExists = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '友だちを追加',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                const SizedBox(height: 150),
                SizedBox(
                  width: 250,
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: 'ユーザー名',
                      ),
                      autofocus: true,
                      validator: (value) {
                        if (!_nameExists) {
                          return 'そのユーザーは存在しません';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ArrowButton(
                      backgroundColor: Colors.grey.shade200,
                      icon: Icons.arrow_back,
                      iconColor: Colors.blueGrey,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ArrowButton(
                      backgroundColor: Colors.blue,
                      icon: Icons.arrow_forward,
                      iconColor: Colors.white,
                      onPressed: () async {
                        await checkNameExists(_controller.text);
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(context).pushNamed(
                            FriendRequestScreen.id,
                            arguments: friendUid,
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
