import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Driver/helper/alertbox.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class User {
  User({required this.uid});
  final String uid;
}

abstract class AuthBase {
  Future<User> currentUser();
  Future<User> signInAnonymously();
  Future<User> signInWithGoogle();
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<User> createUserWithEmailAndPassword(Map<String, dynamic> userMap);
  Future<void> signOut();
}

class Auth implements AuthBase {
  final AlertBox alertBox = AlertBox();
  final _firebaseAuth = FirebaseAuth.instance;

  User _userFromFirebase(user) {
    if (user == null) {
      // Throw an exception
      throw Exception('User is null');

      // or Return a default User object
      // return User(uid: '');
    }
    return User(uid: user.uid);
  }

  @override
  Future<User> currentUser() async {
    final user = _firebaseAuth.currentUser;
    return _userFromFirebase(user);
  }

  @override
  Future<User> signInAnonymously() async {
    final authResult = await _firebaseAuth.signInAnonymously();
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<User> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final googleAccount = await googleSignIn.signIn();

    if (googleAccount != null) {
      GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;
      print("${googleAuth.accessToken}, ${googleAuth.idToken}");
      if (1 == 1) {
        final authResult = await _firebaseAuth.signInWithCredential(
          GoogleAuthProvider.credential(
            idToken: googleAuth.idToken,
            accessToken: googleAuth.accessToken,
          ),
        );
        return _userFromFirebase(authResult.user);
      } else {
        throw Exception(
          'Missing Google Auth Token',
        );
      }
    }
    throw Exception('Sign in with Google aborted');
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    final authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<User> createUserWithEmailAndPassword(
      Map<String, dynamic> userMap) async {
    final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
      email: userMap['email'].toString(),
      password: userMap['password'].toString(),
    );
    final currentUser = authResult.user;
    //creating user profile after creating User with email and password
    createUserProfile(currentUser, userMap);
    return _userFromFirebase(authResult.user);
  }

  Future<void> createUserProfile(
      currentUser, Map<String, dynamic> userMap) async {
    if (currentUser != null) {
      try {
        String userUid = currentUser!.uid;

        // Store additional user profile information in Firestore
        // await FirebaseFirestore.instance
        //     .collection('drivers')
        //     .doc(userUid)
        //     .set(userMap);

        userMap['id'] = userUid;

        // Store additional user profile information in the Realtime Database
        DatabaseReference userRef =
            FirebaseDatabase.instance.ref().child('drivers').child(userUid);

        await userRef.set(userMap);

        Fluttertoast.showToast(msg: "registration successful");
      } catch (err) {
        Fluttertoast.showToast(msg: err.toString());
      }
    }
  }

  Future<bool?> addDriverInformation(Map<String, dynamic> driverInfo) async {
    try {
      final user = _firebaseAuth.currentUser;
      // Update the existing user profile information in Firestore with the new data
      // await FirebaseFirestore.instance
      //     .collection('drivers')
      //     .doc(user!.uid)
      //     .collection("information")
      //     .add(driverInfo);

      DatabaseReference driverRef = FirebaseDatabase.instance
          .ref()
          .child('drivers')
          .child(user!.uid)
          .child('information');
      await driverRef.set(driverInfo);

      Fluttertoast.showToast(msg: "Submitted successfully");
      return true;
    } catch (err) {
      Fluttertoast.showToast(msg: err.toString());
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    _userFromFirebase(null);
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
