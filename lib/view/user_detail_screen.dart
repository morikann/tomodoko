import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';
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
  double bearing = 0.0;
  Location myLocation = Location();
  Location opponentLocation = Location();
  final streamController = StreamController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addMySubscription();
    addOpponentSubscription();
  }

  void addMySubscription() {
    _fireStore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .snapshots()
        .listen((e) {
      myLocation.latitude = e.data()?['latitude'];
      myLocation.longitude = e.data()?['longitude'];
      if (!mounted) {
        return;
      }
      setState(() {
        getDistance();
        getBearing();
      });
    });
  }

  void addOpponentSubscription() {
    _fireStore
        .collection('users')
        .doc(widget.opponentUid)
        .snapshots()
        .listen((e) {
      opponentLocation.latitude = e.data()?['latitude'];
      opponentLocation.longitude = e.data()?['longitude'];
      if (!mounted) {
        return;
      }
      setState(() {
        getDistance();
        getBearing();
      });
    });
  }

  void getDistance() {
    Location location = Location();
    distance = location.calculateDistance(
      myLocation.latitude,
      myLocation.longitude,
      opponentLocation.latitude,
      opponentLocation.longitude,
    );
  }

  void getBearing() {
    Location location = Location();
    bearing = location.calculateBearing(
      myLocation.latitude,
      myLocation.longitude,
      opponentLocation.latitude,
      opponentLocation.longitude,
    );
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
              Center(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                    ),
                    children: [
                      TextSpan(
                        text: distance,
                        style: const TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 50),
                      ),
                      const TextSpan(
                        text: 'm',
                        style: TextStyle(letterSpacing: 5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                child: Transform.rotate(
                  angle: bearing * pi / 180,
                  child: const Image(
                    image: AssetImage('images/navigation.png'),
                    color: Colors.purple,
                  ),
                ),
                height: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
