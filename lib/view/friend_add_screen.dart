import 'package:flutter/material.dart';
import '../component/arrow_button.dart';

class FriendAddScreen extends StatefulWidget {
  static const id = 'friend_add_screen';
  const FriendAddScreen({Key? key}) : super(key: key);

  @override
  _FriendAddScreenState createState() => _FriendAddScreenState();
}

class _FriendAddScreenState extends State<FriendAddScreen> {
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
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: 'ユーザー名',
                    ),
                    autofocus: true,
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
                      onPressed: () {},
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
