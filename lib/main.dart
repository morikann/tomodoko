import 'package:flutter/material.dart';
import 'view/signup_screen.dart';
import 'view/home_screen.dart';
import 'view/login_screen.dart';
import 'view/user_list_screen.dart';
import 'view/user_detail_screen.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        HomeScreen.id: (context) => const HomeScreen(),
        SignupScreen.id: (context) => const SignupScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        UserListScreen.id: (context) => const UserListScreen(),
        UserDetailScreen.id: (context) => const UserDetailScreen(),
      },
    );
  }
}
