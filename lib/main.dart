import 'package:flutter/material.dart';
import 'view/signup_screen.dart';
import 'view/home_screen.dart';
import 'view/login_screen.dart';
import 'view/user_list_screen.dart';
import 'view/user_detail_screen.dart';

void main() {
  runApp(const Tomodoko());
}

class Tomodoko extends StatelessWidget {
  const Tomodoko({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tomodoko',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      initialRoute: HomeScreen.id,
      routes: {
        HomeScreen.id: (context) => HomeScreen(),
        SignupScreen.id: (context) => SignupScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        UserListScreen.id: (context) => UserListScreen(),
        UserDetailScreen.id: (context) => UserDetailScreen(),
      },
    );
  }
}
