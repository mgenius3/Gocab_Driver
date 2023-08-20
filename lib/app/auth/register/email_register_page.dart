import 'package:flutter/material.dart';
import 'package:Driver/services/auth.dart';
import './email_register_form.dart';

class EmailRegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
          backgroundColor: Colors.white,
          title: Text(
            "Register",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: ListView(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
              child: EmailRegisterForm(
                auth: Auth(),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[200],
      ),
    );
  }
}
