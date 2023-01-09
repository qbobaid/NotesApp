import 'package:flutter/material.dart';
import 'package:notes_app/utilities/dialog/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Sharing",
    content: 'Cannot share empty note!',
    optionBuilder: () => {'Ok': null},
  );
}
