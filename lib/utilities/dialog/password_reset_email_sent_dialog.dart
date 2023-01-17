import 'package:flutter/material.dart';
import 'package:notes_app/extensions/buildcontext/localization.dart';
import 'package:notes_app/utilities/dialog/generic_dialog.dart';

Future<void> showPasswordResetEmailSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: context.loc.password_reset,
    content: context.loc.password_reset_dialog_prompt,
    optionBuilder: () =>  {
      context.loc.ok: null
    },
  );
}
