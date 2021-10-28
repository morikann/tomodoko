import 'package:flutter/material.dart';

class UserDetailScreen extends StatelessWidget {
  static const id = 'user_detail_screen';
  const UserDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ユーザー詳細',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '太郎との距離は...',
                style: TextStyle(fontSize: 20),
              ),
              const Text(
                '200m',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                child: Image.asset('images/navigation.png'),
                height: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
