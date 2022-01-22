import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tomodoko/services/firestore.dart';
import 'package:tomodoko/view/friend/friend_add_screen.dart';
import 'package:tomodoko/view/friend/friend_request_list_screen.dart';
import 'package:tomodoko/view/friend/friend_request_screen.dart';
import 'view/home_screen.dart';
import 'view/signup_screen.dart';
import 'view/welcome_screen.dart';
import 'view/login_screen.dart';
import 'view/user_list_screen.dart';
import 'view/user_detail_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'model/user_detail_screen_arguments.dart';
import 'view/user_edit_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );
  await Firebase.initializeApp();
  runApp(const Tomodoko());
}

class Tomodoko extends StatelessWidget {
  const Tomodoko({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'tomodoko',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: Firestore().isLogin() ? HomeScreen.id : WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        SignupScreen.id: (context) => const SignupScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        UserListScreen.id: (context) => const UserListScreen(),
        HomeScreen.id: (context) => const HomeScreen(),
        UserEditScreen.id: (context) => const UserEditScreen(),
        FriendAddScreen.id: (context) => const FriendAddScreen(),
        FriendRequestListScreen.id: (context) =>
            const FriendRequestListScreen(),
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
              friendUid: args.uid,
              friendName: args.name,
              friendImage: args.image,
            );
          });
        }
        if (settings.name == FriendRequestScreen.id) {
          final args = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) {
              return FriendRequestScreen(friendUid: args);
            },
          );
        }
      },
    );
  }
}
