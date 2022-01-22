import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tomodoko/model/user_detail_screen_arguments.dart';
import 'package:tomodoko/view/friend/friend_add_screen.dart';
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
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  Timer? _timer;
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('ホーム', style: TextStyle(fontSize: 18));
  String? searchWord;
  List<QueryDocumentSnapshot> mutualSnapshotList = [];
  late bool _isToggle;
  bool _loading = true;
  bool _loadToggle = true;

  Future<void> getMutualUsers() async {
    final followList = await getFollowingUsers();
    final mutualFollowList = await getFollowerUsers(followList);
    await getMutualFollowerUsers(mutualFollowList).then((mutualFollowers) {
      setState(() {
        mutualSnapshotList = mutualFollowers;
        _loading = false;
      });
    });
  }

  Future<List> getFollowingUsers() async {
    var followList = [];
    mutualSnapshotList = [];

    await _fireStore
        .collection('follows')
        .where('following_uid', isEqualTo: _auth.currentUser?.uid)
        .get()
        .then((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        followList.add(doc["followed_uid"]);
      }
    });

    return followList;
  }

  Future<List> getFollowerUsers(List followList) async {
    var mutualFollowList = [];
    var followerList = [];

    // followしているユーザーがいなかったら即リターン
    if (followList.isEmpty) {
      return mutualFollowList;
    }

    await _fireStore
        .collection('follows')
        .where('followed_uid', isEqualTo: _auth.currentUser?.uid)
        .get()
        .then((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        followerList.add(doc["following_uid"]);
      }
      for (var follow in followList) {
        if (followerList.contains(follow)) {
          mutualFollowList.add(follow);
        }
      }
      // 重複を無くす
      mutualFollowList = mutualFollowList.toSet().toList();
    });

    return mutualFollowList;
  }

  Future<List<QueryDocumentSnapshot>> getMutualFollowerUsers(
      List mutualFollowList) async {
    for (var follow in mutualFollowList) {
      await _fireStore
          .collection('users')
          .where('uid', isEqualTo: follow)
          .get()
          .then((QuerySnapshot snapshot) {
        if (snapshot.docs.isNotEmpty) {
          mutualSnapshotList.add(snapshot.docs.first);
        }
      });
    }
    return mutualSnapshotList;
  }

  Future<void> _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isToggle = prefs.getBool('isToggle') ?? false;
      _loadToggle = false;
    });
    if (_isToggle) {
      await updateLocationInfo();
    }
  }

  Future<void> updateLocationInfo() async {
    print('位置情報取得開始');
    await getLocation();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      getLocation();
    });
  }

  Future<void> getLocation() async {
    final location = Location();
    await location.getCurrentLocation();
    await registerLocation(location);
  }

  Future<void> registerLocation(Location location) async {
    // 緯度か経度が登録されてなかったら更新しない
    if (location.latitude == null || location.longitude == null) {
      if (_isToggle && mounted) {
        setState(() {
          _isToggle = false;
        });
      }
      if (_timer != null) {
        _timer!.cancel();
      }
      return;
    }
    if (_auth.currentUser == null) {
      return;
    }
    final _uid = _auth.currentUser!.uid;
    await _fireStore.collection('users').doc(_uid).update({
      'latitude': location.latitude,
      'longitude': location.longitude,
      'updated_at': DateTime.now(),
    }).then(
      (value) {
        print('登録できました');
      },
    ).catchError(
      (e) => print('登録できませんでした。：$e'),
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

  Future<void> _setToggleInfoToLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isToggle', _isToggle);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMutualUsers();
    _load();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (_timer != null) {
      _timer!.cancel();
    }
    _setToggleInfoToLocal();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(FriendAddScreen.id);
        },
        label: const Text('友だちを追加'),
        icon: const Icon(Icons.add_reaction),
        backgroundColor: Colors.pink,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '友だち一覧',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_loadToggle) ...[
              const SizedBox.shrink(),
            ] else ...[
              _buildToggle(),
            ],
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : mutualSnapshotList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                '友だちを追加しよう！',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Icon(
                                Icons.arrow_downward,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        )
                      : ListView(
                          children: mutualSnapshotList.map(
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
                                        data['imgURL'],
                                      ),
                                    );
                                  },
                                  leading: data['imgURL'] == null
                                      ? CircleAvatar(
                                          backgroundColor: Colors.grey.shade400,
                                          radius: 20,
                                          child: const CircleAvatar(
                                            radius: 19,
                                            backgroundImage: AssetImage(
                                                'images/default.png'),
                                            backgroundColor: Colors.white,
                                          ),
                                        )
                                      : CircleAvatar(
                                          backgroundColor: Colors.grey.shade400,
                                          radius: 20,
                                          child: CircleAvatar(
                                            radius: 19,
                                            backgroundImage:
                                                NetworkImage(data['imgURL']),
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
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openLocationSettingDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const SizedBox.shrink(),
          content: const Text(
            '現在地を取得できません。友達との距離を計測するには、アプリによる位置情報の利用を設定から許可してください。',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                bool isOpen = await Geolocator.openAppSettings();
                if (isOpen) {
                  Navigator.pop(context);
                }
              },
              child: const Text('設定を開く'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '位置情報',
          style: TextStyle(
            color: _isToggle ? Colors.blue.shade300 : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        Switch(
          onChanged: (bool value) async {
            LocationPermission permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.denied ||
                permission == LocationPermission.deniedForever) {
              await openLocationSettingDialog();

              return;
            }
            setState(() {
              _isToggle = value;
            });
            if (_isToggle) {
              updateLocationInfo();
            } else {
              if (_timer != null) {
                _timer!.cancel();
              }
            }
          },
          value: _isToggle,
        ),
      ],
    );
  }
}
