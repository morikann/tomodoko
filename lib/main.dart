import 'package:flutter/material.dart';
import 'view/home_screen.dart';
import 'view/signup_screen.dart';
import 'view/welcome_screen.dart';
import 'view/login_screen.dart';
import 'view/user_list_screen.dart';
import 'view/user_detail_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'model/user_detail_screen_arguments.dart';

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
        primarySwatch: Colors.blue,
      ),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        SignupScreen.id: (context) => const SignupScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        UserListScreen.id: (context) => const UserListScreen(),
        HomeScreen.id: (context) => const HomeScreen(),
      },
      // ModalRoute.of(context)!.settings.arguments as UserDetailScreenArguments;で
      // 遷移元から遷移先に値を渡せるが、取得できる場所がbuildメソッド内になってしまう。
      // nameを表示するだけならそれでもいいが、uidはfireStoreとやりとりするためにもプロパティとして
      // 欲しいのでonGenerateRouteを使う。
      onGenerateRoute: (settings) {
        if (settings.name == UserDetailScreen.id) {
          final args = settings.arguments as UserDetailScreenArguments;
          return MaterialPageRoute(builder: (context) {
            return UserDetailScreen(
              opponentUid: args.uid,
              opponentName: args.name,
              timerCancel: args.timerCancel,
            );
          });
        }
      },
    );
  }
}
