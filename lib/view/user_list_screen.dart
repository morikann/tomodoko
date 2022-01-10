import 'dart:async';
import 'package:flutter/material.dart';
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
  late Timer _timer;
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('ホーム', style: TextStyle(fontSize: 18));
  String? searchWord;
  List<QueryDocumentSnapshot> mutualSnapshotList = [];

  Future<List<QueryDocumentSnapshot>> getMutualFuture() async {
    final followList = await getFollowingUsers();
    final mutualFollowList = await getFollowerUsers(followList);
    mutualSnapshotList = await getMutualFollowerUsers(mutualFollowList);
    return mutualSnapshotList;
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
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      getLocation();
    });
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
        title: const Text(
          '友だち一覧',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        // title: customSearchBar,
        // actions: [
        //   IconButton(
        //     onPressed: () async {
        //       setState(() {
        //         if (customIcon.icon == Icons.search) {
        //           customIcon = const Icon(Icons.cancel);
        //           customSearchBar = Container(
        //             height: 40,
        //             decoration: BoxDecoration(
        //               color: Colors.white,
        //               borderRadius: BorderRadius.circular(20),
        //             ),
        //             child: TextField(
        //               textAlignVertical: TextAlignVertical.center,
        //               decoration: const InputDecoration(
        //                 // 無理矢理paddingをつけて高さを調整しているが、他に方法はないのか...
        //                 // contentPadding: EdgeInsets.only(top: 5),
        //                 // -> prefixIconが設定れている時は、verticalAlignとisCollapsedを設定したらできた
        //                 prefixIcon: Icon(Icons.search),
        //                 hintText: 'ユーザー検索',
        //                 hintStyle: TextStyle(
        //                   color: Colors.grey,
        //                 ),
        //                 border: InputBorder.none,
        //                 isCollapsed: true,
        //               ),
        //               style: const TextStyle(
        //                 color: Colors.black,
        //               ),
        //               onChanged: (value) {
        //                 setState(() {
        //                   searchWord = value;
        //                 });
        //               },
        //             ),
        //           );
        //         } else {
        //           setState(() {
        //             searchWord = '';
        //           });
        //           customIcon = const Icon(Icons.search);
        //           customSearchBar = const Text(
        //             'ホーム',
        //             style: TextStyle(fontSize: 18),
        //           );
        //         }
        //       });
        //     },
        //     icon: customIcon,
        //   )
        // ],
      ),
      body: SafeArea(
        child: FutureBuilder(
          // stream: (searchWord != '' && searchWord != null)
          //     ? FirebaseFirestore.instance // searchWordから始まる文字の検索(LIKE検索っぽい)
          //         .collection('users')
          //         .orderBy('name')
          //         .startAt([searchWord]).endAt(
          //             ['$searchWord\uf8ff']).snapshots()
          //     : mutualFollowers,
          future: getMutualFuture(),
          builder: (BuildContext context,
              AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
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
              );
            }

            return ListView(
              children: snapshot.data!.map(
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
                              backgroundColor: Colors.grey.shade400,
                              radius: 20,
                              child: const CircleAvatar(
                                radius: 19,
                                backgroundImage:
                                    AssetImage('images/default.png'),
                                backgroundColor: Colors.white,
                              ),
                            )
                          : CircleAvatar(
                              backgroundColor: Colors.grey.shade400,
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
