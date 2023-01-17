import 'package:flutter/material.dart';
import 'package:notes_app/extensions/buildcontext/localization.dart';
import 'package:notes_app/utilities/dialog/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog(
    context: context,
    title: context.loc.generic_error_prompt,
    content: text,
    optionBuilder: () => {
      context.loc.ok: null,
    },
  );
}
