import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FriendRequestListScreen extends StatefulWidget {
  static const id = 'friend_request_list_screen';
  const FriendRequestListScreen({Key? key}) : super(key: key);

  @override
  _FriendRequestListScreenState createState() =>
      _FriendRequestListScreenState();
}

class _FriendRequestListScreenState extends State<FriendRequestListScreen> {
  Future<QuerySnapshot>? requestUsersFuture;
  bool _loading = false;

  void getFollowerUsers() {
    setState(() {
      _loading = true;
    });
    var followerList = [];
    FirebaseFirestore.instance
        .collection('follows')
        .where('followed_uid',
            isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        followerList.add(doc["following_uid"]);
      }
      getRequestUsers(followerList);
    }).catchError((e) {
      setState(() {
        _loading = false;
      });
    });
  }

  void getRequestUsers(List followerList) {
    var followingList = [];
    var requestList = [];

    FirebaseFirestore.instance
        .collection('follows')
        .where('following_uid',
            isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        followingList.add(doc["followed_uid"]);
      }
      // フォローされていて、フォローしていないユーザーを取得
      for (var follower in followerList) {
        if (!followingList.contains(follower)) {
          requestList.add(follower);
        }
      }
      getRequestUserInfo(requestList);
    }).catchError((e) {
      setState(() {
        _loading = false;
      });
    });
  }

  void getRequestUserInfo(List requestUsers) {
    requestUsersFuture = FirebaseFirestore.instance
        .collection('users')
        .where('uid', whereIn: requestUsers)
        .get();
    setState(() {
      _loading = false;
    });
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
  void initState() {
    // TODO: implement initState
    super.initState();
    getFollowerUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '友だちリクエスト',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : FutureBuilder<QuerySnapshot>(
                future: requestUsersFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text(
                        '友だちリクエストはありません',
                        style: TextStyle(fontSize: 16),
                      ),
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
                            onTap: () {},
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
                  );
                },
              ),
      ),
    );
  }
}
