import 'package:Driver/Assistants/assistant_method.dart';
import 'package:flutter/material.dart';
import 'package:Driver/app/landing_page.dart';
import 'package:Driver/services/auth.dart';
import 'package:Driver/services/auth.dart';
import 'dart:async';
import "package:firebase_auth/firebase_auth.dart";
import 'package:fluttertoast/fluttertoast.dart';
import 'package:Driver/app/auth/signIn/email_sign_in_page.dart';
import 'package:Driver/app/sub_screens/map_screen.dart';
import 'package:provider/provider.dart';
import 'package:Driver/app/auth/register/driver_info.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final auth = Auth();

  startTimer() {
    Timer(Duration(seconds: 3), () async {
      if (await FirebaseAuth.instance.currentUser != null) {
        FirebaseAuth.instance.currentUser != null
            ? AssistantMethods.readCurrentOnlineUserInfo()
            : null;
        Navigator.push(context, MaterialPageRoute(builder: (c) => MapScreen()));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => EmailSignInPage()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0B81),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/Gb.png', // Replace with the path to your image
              fit: BoxFit.cover, // Adjust the image fit as needed
            ),
          ],
        ),
      ),
    );
  }
}
