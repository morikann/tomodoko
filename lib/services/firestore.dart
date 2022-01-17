import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../view/home_screen.dart';

class Firestore {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _nameExists = false;
  User? _currentUser;

  bool get nameExists {
    return _nameExists;
  }

  bool isLogin() {
    _currentUser = _auth.currentUser;
    return _currentUser != null;
  }

  Future<void> checkNameExists(String name) async {
    final QuerySnapshot result = await _firestore
        .collection('users')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.length == 1) {
      _nameExists = true;
    } else {
      _nameExists = false;
    }
  }

  Future<void> saveUser(
      String uid, String name, String email, BuildContext context) async {
    return await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
    }).then((value) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        HomeScreen.id,
        (route) => false,
      );
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('予期せぬエラーが発生しました: $e'),
        ),
      );
    });
  }

  Future<String?> signup(
      String email, String password, BuildContext context) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('$emailは既に登録されています'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('予期せぬエラーが発生しました: $e'),
        ),
      );
    }
  }

  Future<void> signIn(
      String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.of(context).pushNamedAndRemoveUntil(
        HomeScreen.id,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('メールアドレスが見つかりませんでした'),
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('パスワードが正しくありません'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('予期せぬエラーが発生しました: $e'),
        ),
      );
    }
  }
}
