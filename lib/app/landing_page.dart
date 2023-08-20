import 'package:flutter/material.dart';
import 'package:Driver/app/home_page.dart';
import 'package:Driver/services/auth.dart';

//////////////
import 'package:Driver/app/auth/register/email_register_page.dart';
import 'package:Driver/app/auth/signIn/email_sign_in_page.dart';

class LandingPage extends StatefulWidget {
  LandingPage({required this.auth});
  final AuthBase auth;
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  var _user;

  @override
  void initState() {
    super.initState();
    print(_user);
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    //making sure the user remain signed in even after restart;
    var user = await widget.auth.currentUser;
    print(user);
    _updateUser(user);
  }

  void _updateUser(user) async {
    // user = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      // return SignPage(
      //   auth: widget.auth,
      //   onSignIn: (user) => _updateUser(user),
      // );
      return EmailSignInPage();
    }
    // return TaxiDriverRegistrationPage();
    // print(_user);
    // return BookingPage();
    return EmailSignInPage();
  }
}
