import 'package:flutter/material.dart';
import 'package:tomodoko/view/home_screen.dart';
import '../model/user.dart';

class UsersScreen extends StatefulWidget {
  static const id = 'users_screen';
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> users = [
    User(username: '田中 太郎'),
    User(username: '東 太郎'),
    User(username: '隣の 太郎'),
    User(username: 'taro'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ユーザー一覧',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {},
              child: ListTile(
                // 余裕があればユーザーの画像に変更
                leading: const Icon(Icons.face),
                title: Text(users[index].username),
                trailing: const Icon(Icons.arrow_right),
              ),
            );
          },
        ),
      ),
    );
  }
}
