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
  List<QueryDocumentSnapshot> documentSnapshotList = [];
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot>> getRequestFuture() async {
    final followerList = await getFollowerUsers();
    final requestUsersList = await getRequestUsers(followerList);
    documentSnapshotList = await getRequestUserInfo(requestUsersList);
    return documentSnapshotList;
  }

  Future<List> getFollowerUsers() async {
    documentSnapshotList = [];
    var followerList = [];
    await _fireStore
        .collection('follows')
        .where('followed_uid', isEqualTo: _auth.currentUser?.uid)
        .get()
        .then((QuerySnapshot snapshot) async {
      for (var doc in snapshot.docs) {
        followerList.add(doc["following_uid"]);
      }
    });
    return followerList;
  }

  Future<List> getRequestUsers(List followerList) async {
    var followingList = [];
    var requestList = [];

    await _fireStore
        .collection('follows')
        .where('following_uid', isEqualTo: _auth.currentUser?.uid)
        .get()
        .then((QuerySnapshot snapshot) async {
      for (var doc in snapshot.docs) {
        followingList.add(doc["followed_uid"]);
      }
      // フォローされていて、フォローしていないユーザーを取得
      for (var follower in followerList) {
        if (!followingList.contains(follower)) {
          requestList.add(follower);
        }
      }
    });

    return requestList;
  }

  Future<List<QueryDocumentSnapshot>> getRequestUserInfo(
      List requestUsers) async {
    for (var uid in requestUsers) {
      await _fireStore
          .collection('users')
          .where('uid', isEqualTo: uid)
          .get()
          .then((QuerySnapshot snapshot) {
        documentSnapshotList.add(snapshot.docs.first);
      });
    }
    return documentSnapshotList;
  }

  String updateTime(Timestamp? date) {
    if (date == null) {
      return 'Location not registered';
    }
    final dateTime = date.toDate();
    final dateFormat = DateFormat('y/M/d HH:mm');
    return "更新日: ${dateFormat.format(dateTime)}";
  }

  Future<void> approveRequest(String friendUid) async {
    await _fireStore.collection('follows').add({
      'following_uid': _auth.currentUser?.uid,
      'followed_uid': friendUid,
    }).then((_) async {
      // リビルドしてFutureBuilderのfutureを発火
      setState(() {});
    }).catchError((e) => print(e));
  }

  Future<void> denyRequest(String friendUid) async {
    await _fireStore
        .collection('follows')
        .where('following_uid', isEqualTo: friendUid)
        .where('followed_uid', isEqualTo: _auth.currentUser?.uid)
        .get()
        .then((QuerySnapshot snapshot) async {
      final docId = snapshot.docs.first.id;
      await removeRequest(docId);
    }).catchError((e) => print(e));
  }

  Future<void> removeRequest(String docId) async {
    await _fireStore.collection('follows').doc(docId).delete().then(
      (_) async {
        setState(() {});
      },
    ).catchError((e) => print(e));
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
        child: FutureBuilder(
          future: getRequestFuture(),
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
              return const Center(
                child: Text(
                  '友だちリクエストはありません',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView(
              children: snapshot.data!.map(
                (DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  return ListTile(
                    leading: data['imgURL'] == null
                        ? CircleAvatar(
                            backgroundColor: Colors.blue.shade200,
                            radius: 20,
                            child: const CircleAvatar(
                              radius: 19,
                              backgroundImage: AssetImage('images/default.png'),
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
                    subtitle: Text(
                      updateTime(data['updated_at']),
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    trailing: Wrap(
                      spacing: 10,
                      children: [
                        RequestButton(
                          label: '承認',
                          textColor: Colors.white,
                          backgroundColor: Colors.blue,
                          onTap: () async {
                            await approveRequest(data['uid']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text('承認しました'),
                              ),
                            );
                          },
                        ),
                        RequestButton(
                          label: '削除',
                          textColor: Colors.black,
                          backgroundColor: Colors.grey.shade300,
                          onTap: () async {
                            await denyRequest(data['uid']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text('削除しました'),
                              ),
                            );
                          },
                        )
                      ],
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

class RequestButton extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color backgroundColor;
  final VoidCallback onTap;
  const RequestButton({
    Key? key,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: backgroundColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
          ),
        ),
      ),
    );
  }
}
