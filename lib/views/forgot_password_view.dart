import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/services/auth/auth_exceptions.dart';
import 'package:notes_app/services/auth/bloc/auth_bloc.dart';
import 'package:notes_app/services/auth/bloc/auth_event.dart';
import 'package:notes_app/utilities/dialog/error_dialog.dart';
import 'package:notes_app/utilities/dialog/password_reset_email_sent_dialog.dart';

import '../services/auth/bloc/auth_state.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetEmailSentDialog(context);
          }
          if (state.exception != null) {
            if(state.exception is UserNotFoundAuthException) {
              await showErrorDialog(
                context,
                'User in not registered, please register a user by going back one step',
              );
            } else if(state.exception is InvalidEmailAuthException) {
              await showErrorDialog(
                context,
                'Invalid email, please provide a valid email',
              );
            } else {
              await showErrorDialog(
                context,
                'Unable to process your request. Please make sure you are a registered user, if not, please register a user by going back one step',
              );
            }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forgot password'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                    'Please enter your email below so we can send you a password reset link in your email'),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _controller,
                  autocorrect: false,
                  autofocus: true,
                  decoration:
                      const InputDecoration(hintText: 'Your email address...'),
                ),
                TextButton(
                  onPressed: () {
                    final email = _controller.text;
                    context.read<AuthBloc>().add(AuthEventForgotPassword(email: email));
                  },
                  child: const Text('Send me password reset link'),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEventLogout());
                  },
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
