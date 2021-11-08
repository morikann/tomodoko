import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/location.dart';

class UserDetailScreen extends StatefulWidget {
  static const id = 'user_detail_screen';
  final String opponentUid;
  final String opponentName;
  final Function timerCancel;

  const UserDetailScreen({
    Key? key,
    required this.opponentUid,
    required this.opponentName,
    required this.timerCancel,
  }) : super(key: key);

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  String distance = '';
  String bearing = '';
  Location myLocation = Location();
  Location opponentLocation = Location();
  final streamController = StreamController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // ユーザーのdbの変更を受信し、コントローラのstreamに追加する
    // 非同期処理の順序が追えないコードになっているので改善の余地あり
    addStreamToController();
    setLocation();
  }

  void addStreamToController() async {
    // streamControllerにイベント(stream)を追加中に、新しいイベントを追加するとエラーが生じるので、
    // 一つの関数にまとめてinitStateで実行する
    await streamController.addStream(
        _fireStore.collection('users').doc(_auth.currentUser!.uid).snapshots());
    await streamController.addStream(
        _fireStore.collection('users').doc(widget.opponentUid).snapshots());
  }

  Future<void> getOpponentLocation() async {
    final String _uid = widget.opponentUid;
    await _fireStore.collection('users').doc(_uid).get().then((snapshot) {
      opponentLocation.latitude = snapshot.data()?['latitude'];
      opponentLocation.longitude = snapshot.data()?['longitude'];
    }).catchError((e) => print(e));
  }

  Future<void> getMyLocation() async {
    final String _uid = _auth.currentUser!.uid;
    await _fireStore.collection('users').doc(_uid).get().then(
      (snapshot) {
        myLocation.latitude = snapshot.data()?['latitude'];
        myLocation.longitude = snapshot.data()?['longitude'];
      },
    ).catchError((e) => print(e));
  }

  void getDistance() {
    Location location = Location();
    distance = location.calculateDistance(
      myLocation.longitude,
      myLocation.longitude,
      opponentLocation.latitude,
      opponentLocation.longitude,
    );
  }

  void getBearing() {
    Location location = Location();
    bearing = location.calculateBearing(
      myLocation.longitude,
      myLocation.longitude,
      opponentLocation.latitude,
      opponentLocation.longitude,
    );
  }

  Future<void> setLocation() async {
    streamController.stream.listen((_) async {
      await getMyLocation();
      await getOpponentLocation();
      if (!mounted) {
        return;
      }
      setState(() {
        getDistance();
        getBearing();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.opponentName,
          style: const TextStyle(fontSize: 18),
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
                          widget.timerCancel();
                          Navigator.of(context)
                              .pushReplacementNamed(HomeScreen.id);
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${widget.opponentName}との距離は...',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                '${distance}m',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                child: Image.asset('images/navigation.png'),
                height: 200,
              ),
              Text('方位: $bearing'),
            ],
          ),
        ),
      ),
    );
  }
}
