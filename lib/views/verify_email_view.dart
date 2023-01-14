import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/services/auth/bloc/auth_bloc.dart';
import 'package:notes_app/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text("Verification email has been sent to your account, Please open it to verify your account"),
              const Text("If you haven't received the email, press the button below"),
              TextButton(
                  onPressed: () async {
                    context.read<AuthBloc>().add(const AuthEventSendEmailVerification());
                  },
                  child: const Text("Send verification email")
              ),
              TextButton(
                  onPressed: () async {
                    context.read<AuthBloc>().add(const AuthEventLogout());
                  },
                  child: const Text("Restart")
              ),
            ],
          ),
        ),
      ),
    );
  }
}