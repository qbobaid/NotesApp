import 'package:flutter/material.dart';
import 'package:notes_app/utilities/dialog/generic_dialog.dart';

Future<void> showPasswordResetEmailSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Password reset',
    content: 'We have sent you an email to reset your password. Please check your email',
    optionBuilder: () =>  {
      'Ok': null
    },
  );
}
