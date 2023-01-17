import 'package:flutter/material.dart';
import 'package:notes_app/extensions/buildcontext/localization.dart';
import 'package:notes_app/services/auth/auth_service.dart';
import 'package:notes_app/services/cloud/cloud_note.dart';
import 'package:notes_app/services/cloud/firebase_cloud_storage.dart';
import 'package:notes_app/utilities/dialog/cannot_share_empty_note_dialog.dart';
import 'package:notes_app/utilities/generics/get_arguments.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCouldStorage _notesService;
  late final TextEditingController _textEditingController;

  void _textEditingControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    await _notesService.updateNote(
      documentId: note.documentId,
      text: _textEditingController.text,
    );
  }

  void _setupTextEditingControllerListener() {
    _textEditingController.removeListener(_textEditingControllerListener);
    _textEditingController.addListener(_textEditingControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      _textEditingController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final note = await _notesService.createNewNote(ownerUserId: userId);
    _note = note;
    return note;
  }

  void _deleteNoteIfTextIsEmpty() async {
    final note = _note;
    if (note != null && _textEditingController.text.isEmpty) {
      await _notesService.deleteNote(
        documentId: note.documentId,
      );
    }
  }

  void _saveNoteIfTextIsNotEmpty() async {
    final note = _note;
    final text = _textEditingController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        documentId: note.documentId,
        text: text,
      );
    }
  }

  @override
  void initState() {
    _notesService = FirebaseCouldStorage();
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextIsNotEmpty();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.note),
        actions: [
          IconButton(onPressed: () async {
            final text = _textEditingController.text;
            if(_note == null || text.isEmpty) {
              await showCannotShareEmptyNoteDialog(context);
            } else {
              await Share.share(text);
            }
          }, icon: const Icon(Icons.share))
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextEditingControllerListener();
              return TextField(
                controller: _textEditingController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: context.loc.start_typing_your_note,
                ),
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
