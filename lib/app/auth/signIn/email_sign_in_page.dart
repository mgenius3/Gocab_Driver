import 'package:flutter/material.dart';
import 'package:Driver/app/auth/signIn/email_sign_in_form.dart';
import 'package:Driver/services/auth.dart';

class EmailSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          body: Center(
              child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: EmailSignInForm(
            auth: Auth(),
          ),
        ),
      ))),
    );
  }

  // Widget _buildContent() {
  //   return Container();
  // }
}
