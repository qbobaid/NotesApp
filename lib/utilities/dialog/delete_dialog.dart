import 'package:flutter/material.dart';
import 'package:notes_app/utilities/dialog/generic_dialog.dart';

Future<bool> showDeleteDialog(
    BuildContext context,
    ) {
  return showGenericDialog(
    context: context,
    title: "Delete",
    content: "Are your sure you want to delete this note?",
    optionBuilder: () => {
      'Cancel': false,
      'Yes': true,
    },
  ).then(
        (value) => value ?? false,
  );
}