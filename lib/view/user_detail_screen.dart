import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/location.dart';
import 'package:flutter_compass/flutter_compass.dart';

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
  double? distance;
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCompass(bearing),
                const SizedBox(height: 50),
                Text(
                  '${widget.opponentName}との距離は...',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  height: 20,
                ),
                _setDistanceText(distance),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _setDistanceText(double? distance) {
  String distanceText;
  String? distanceUnit;

  if (distance == null) {
    distanceText = '---';
  } else {
    // 1000m以上の場合、kmに変換
    if (distance >= 1000) {
      distanceText = (distance / 1000).round().toString();
      distanceUnit = 'km';
    } else {
      distanceText = distance.round().toString();
      distanceUnit = 'm';
    }
  }

  return RichText(
    text: TextSpan(
      style: const TextStyle(
        color: Colors.black,
        fontSize: 40,
      ),
      children: [
        TextSpan(
          text: distanceText,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 50,
          ),
        ),
        const WidgetSpan(
          child: SizedBox(
            width: 5,
          ),
        ),
        TextSpan(
          text: distanceUnit,
        ),
      ],
    ),
  );
}

Widget _buildCompass(double bearing) {
  return StreamBuilder<CompassEvent>(
    stream: FlutterCompass.events,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text('Error reading heading: ${snapshot.error}');
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      double? direction = snapshot.data!.heading;

      if (direction == null) {
        return const Center(
          child: Text("Device dose not have sensors"),
        );
      }

      return SizedBox(
        child: Transform.rotate(
          angle: (direction - bearing) * (pi / 180) * -1,
          child: const Image(
            image: AssetImage('images/navigation.png'),
            color: Colors.blue,
          ),
        ),
        height: 200,
      );
    },
  );
}
