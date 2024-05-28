import 'package:Driver/app/home_page.dart';
import 'package:flutter/material.dart';
import "package:Driver/common_widgets/form_submit_button.dart";
import 'package:Driver/app/auth/register/email_register_page.dart';
import 'package:Driver/services/auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:Driver/app/sub_screens/forgot_password.dart';
import 'package:Driver/app/sub_screens/map_screen.dart';
import '../../../utils/helper.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../sub_screens/webview.dart';

class EmailSignInForm extends StatefulWidget {
  EmailSignInForm({required this.auth});
  final AuthBase auth;
  @override
  _EmailSignInFormState createState() => _EmailSignInFormState();
}

class _EmailSignInFormState extends State<EmailSignInForm> {
  bool loading = false;
  bool _isPasswordVisible = false;

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  //declare a Global key
  final _formkey = GlobalKey<FormState>();

  void _submit() async {
    try {
      if (_formkey.currentState!.validate()) {
        setState(
          () {
            loading = true;
          },
        );
        await widget.auth.signInWithEmailAndPassword(
            _emailTextController.text.trim(),
            _passwordTextController.text.trim());
        await Fluttertoast.showToast(msg: "Successfully Logged In");
        loading = false;
        Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
          builder: (context) => MapScreen(),
          fullscreenDialog: true,
        ));
      }
    } catch (e) {
      setState(
        () {
          loading = false;
        },
      );
      if (e is FirebaseException) {
        Fluttertoast.showToast(msg: "Unable to sign in: ${e.message}");
      } else {
        await Fluttertoast.showToast(msg: "Unable to sign in:  try again");
      }
    }
  }

  List<Widget> _buildChildren() {
    return [
      Form(
          key: _formkey,
          child: Column(
            children: [
              // Container(child: Image.asset("images/logo.png")),
              const SizedBox(height: 26),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20)),
                child: Icon(
                  Icons.lock,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 26),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.email_outlined),
                  border:
                      OutlineInputBorder(), // Set the border to a rectangular shape
                ),
                onChanged: (text) => setState(() {
                  _emailTextController.text = text;
                }),
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'Email can\'t be empty';
                  }
                  if (text.length < 2) {
                    return "Please enter a valid email";
                  }
                  if (text.length > 49) {
                    return 'Email can\t be more than 50';
                  }
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border:
                      OutlineInputBorder(), // Set the border to a rectangular shape
                ),
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'Password can\'t be empty';
                  }
                  if (text.length < 6) {
                    return "Password can not be less than 6";
                  }
                  if (text.length > 25) {
                    return 'Password can\'t be more than 25';
                  }
                },
                onChanged: (text) => setState(() {
                  _passwordTextController.text = text;
                }),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: EdgeInsets.all(10)),
                onPressed: !loading ? _submit : null,
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      !loading
                          ? const Text("Sign In",
                              style: TextStyle(fontSize: 24))
                          : const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                backgroundColor: Color(0xFF0D47A1),
                              ))
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const ForgotPasswordScreen()));
                  },
                  child: const Text('Forgot Password ?')),
              const SizedBox(height: 16.0),
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const ForgotPasswordScreen()));
                  },
                  child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WebViewScreen(
                                      url:
                                          "https://gocab.vercel.app/driver/register",
                                      heading: "Driver Registration",
                                    )));
                      },
                      child: const Text('Register as a driver',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)))),
            ],
          ))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildChildren(),
      ),
    );
  }
}
