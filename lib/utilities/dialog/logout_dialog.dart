import 'package:flutter/material.dart';
import 'package:notes_app/utilities/dialog/generic_dialog.dart';

Future<bool> showLogoutDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: "Logout",
    content: "Are your sure you want to logout?",
    optionBuilder: () => {
      'Cancel': false,
      'Logout': true,
    },
  ).then(
    (value) => value ?? false,
  );
}
