import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/extensions/buildcontext/localization.dart';
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
            if (state.exception is UserNotFoundAuthException) {
              await showErrorDialog(
                context,
                context.loc.forgot_password_view_generic_error,
              );
            } else if (state.exception is InvalidEmailAuthException) {
              await showErrorDialog(
                context,
                context.loc.forgot_password_view_generic_error,
              );
            } else {
              await showErrorDialog(
                context,
                context.loc.forgot_password_view_generic_error,
              );
            }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.loc.forgot_password),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  context.loc.forgot_password_view_prompt,
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _controller,
                  autocorrect: false,
                  autofocus: true,
                  decoration:
                      InputDecoration(hintText: context.loc.email_text_field_placeholder),
                ),
                TextButton(
                  onPressed: () {
                    final email = _controller.text;
                    context
                        .read<AuthBloc>()
                        .add(AuthEventForgotPassword(email: email));
                  },
                  child: Text(context.loc.forgot_password_view_send_me_link),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEventLogout());
                  },
                  child: Text(context.loc.forgot_password_view_back_to_login),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
