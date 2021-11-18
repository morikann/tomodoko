import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tomodoko/model/user_detail_screen_arguments.dart';
import 'welcome_screen.dart';
import 'user_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/location.dart';
import 'package:intl/intl.dart';

class UserListScreen extends StatefulWidget {
  static const id = 'users_screen';
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  // 自分は一覧に表示しない
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('users')
      .where('uid', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  late Timer _timer;

  void getLocation() async {
    final location = Location();
    await location.getCurrentLocation();
    registerLocation(location);
  }

  void registerLocation(Location location) {
    // 緯度か経度が登録されてなかったら更新しない
    if (location.latitude == null || location.longitude == null) {
      return;
    }
    final _uid = _auth.currentUser!.uid;
    _fireStore.collection('users').doc(_uid).update({
      'latitude': location.latitude,
      'longitude': location.longitude,
      'updated_at': DateTime.now(),
    }).then(
      (value) {
        print('登録できました');
      },
    ).catchError(
      (e) => print(e),
    );
  }

  String updateTime(Timestamp? date) {
    if (date == null) {
      return 'Location not registered';
    }
    final dateTime = date.toDate();
    final dateFormat = DateFormat('y/M/d HH:mm');
    return "更新日: ${dateFormat.format(dateTime)}";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 呼び出し時に一回発火して、その後10秒毎に発火
    getLocation();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      getLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ホーム',
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
                          // ログアウトしたらタイマーをキャンセル
                          _timer.cancel();
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
        child: StreamBuilder<QuerySnapshot>(
          stream: _usersStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView(
              children: snapshot.data!.docs.map(
                (DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          UserDetailScreen.id,
                          arguments: UserDetailScreenArguments(
                            data['uid'],
                            data['name'],
                            _timer.cancel,
                          ),
                        );
                      },
                      leading: data['imgURL'] == null
                          ? CircleAvatar(
                              backgroundColor: Colors.blue.shade200,
                              radius: 20,
                              child: const CircleAvatar(
                                radius: 19,
                                backgroundImage:
                                    AssetImage('images/default.png'),
                                backgroundColor: Colors.white,
                              ),
                            )
                          : CircleAvatar(
                              backgroundColor: Colors.blue.shade200,
                              radius: 20,
                              child: CircleAvatar(
                                radius: 19,
                                backgroundImage: NetworkImage(data['imgURL']),
                              ),
                            ),
                      title: Text(
                        data['name'],
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      dense: true,
                      subtitle: Text(
                        updateTime(data['updated_at']),
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_right),
                    ),
                  );
                },
              ).toList(),
            );
          },
        ),
      ),
    );
  }
}
