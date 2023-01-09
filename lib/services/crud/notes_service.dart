// import 'dart:async';
//
// import 'package:notes_app/extensions/list/filter.dart';
// import 'package:path/path.dart' show join;
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
//
// import 'crud_exceptions.dart';
//
// class NotesService {
//   Database? _db;
//
//   //create single instance of class
//   static final NotesService _shared = NotesService._sharedInstance();
//
//   NotesService._sharedInstance() {
//     _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
//       onListen: () {
//         _notesStreamController.sink.add(_notes);
//       },
//     );
//   }
//
//   factory NotesService() => _shared;
//
//   //list of notes private to this class
//   List<DatabaseNote> _notes = [];
//
//   DatabaseUser? _user;
//
//   // final _notesStreamController = StreamController<List<DatabaseNote>>.broadcast();
//
//   late final StreamController<List<DatabaseNote>> _notesStreamController;
//
//   Stream<List<DatabaseNote>> get allNotes =>
//       _notesStreamController.stream.filter((note) {
//         final currentUser = _user;
//         if(currentUser != null) {
//           return note.userId == currentUser.id;
//         } else {
//           throw UserShouldBeSetBeforeReadingAllNotes();
//         }
//       });
//
//   Future<void> _cacheNotes() async {
//     final notes = await getAllNotes();
//     _notes = notes.toList();
//     _notesStreamController.add(_notes);
//   }
//
//   Future<DatabaseNote> updateNote(
//       {required DatabaseNote note, required String noteText}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//
//     await getNote(id: note.id);
//
//     final updateCount = await db.update(
//       noteTable,
//       {textColumn: noteText, isSyncWithCloudColumn: 0},
//       where: 'id = ?',
//       whereArgs: [note.id],
//     );
//
//     if (updateCount == 0) {
//       throw CouldNotUpdateNote();
//     } else {
//       final updatedNote = await getNote(id: note.id);
//       _notes.removeWhere((element) => element.id == updatedNote.id);
//       _notes.add(updatedNote);
//       _notesStreamController.add(_notes);
//       return updatedNote;
//     }
//   }
//
//   Future<Iterable<DatabaseNote>> getAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final queryResult = await db.query(noteTable);
//
//     return queryResult.map((row) => DatabaseNote.fromRow(row));
//   }
//
//   Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final user = await getUser(email: owner.email);
//     if (user != owner) {
//       throw CouldNotFindUser();
//     }
//
//     const text = '';
//     final id = await db.insert(
//       noteTable,
//       {
//         userIdColumn: owner.id,
//         textColumn: text,
//         isSyncWithCloudColumn: 1,
//       },
//     );
//
//     final note = DatabaseNote(
//       id: id,
//       userId: owner.id,
//       text: text,
//       isSyncedWithCloud: true,
//     );
//     _notes.add(note);
//     _notesStreamController.add(_notes);
//     return note;
//   }
//
//   Future<DatabaseNote> getNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final queryResult = await db.query(
//       noteTable,
//       limit: 1,
//       where: "id = ?",
//       whereArgs: [id],
//     );
//     if (queryResult.isEmpty) {
//       throw CouldNotFindNote();
//     } else {
//       final note = DatabaseNote.fromRow(queryResult.first);
//       _notes.removeWhere((element) => element.id == id);
//       _notes.add(note);
//       _notesStreamController.add(_notes);
//       return note;
//     }
//   }
//
//   Future<int> deleteAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deleteCount = await db.delete(noteTable);
//     _notes = [];
//     _notesStreamController.add(_notes);
//     return deleteCount;
//   }
//
//   Future<void> deleteNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deleteCount = await db.delete(
//       noteTable,
//       where: "id = ?",
//       whereArgs: [id],
//     );
//     if (deleteCount != 1) {
//       throw UnableToDeleteNote();
//     } else {
//       _notes.removeWhere((element) => element.id == id);
//       _notesStreamController.add(_notes);
//     }
//   }
//
//   Future<DatabaseUser> getOrCreateUser({
//     required String email,
//     bool setAsCurrentUser = true,
//   }) async {
//     await _ensureDbIsOpen();
//     try {
//       final user = await getUser(email: email);
//       if(setAsCurrentUser) {
//         _user = user;
//       }
//       return user;
//     } on CouldNotFindUser {
//       final createdUser = await createUser(email: email);
//       if(setAsCurrentUser) {
//         _user = createdUser;
//       }
//       return createdUser;
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final queryResult = await db.query(
//       userTable,
//       limit: 1,
//       where: "email = ?",
//       whereArgs: [email.toLowerCase()],
//     );
//     if (queryResult.isEmpty) {
//       throw CouldNotFindUser();
//     } else {
//       return DatabaseUser.fromRow(queryResult.first);
//     }
//   }
//
//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final queryResult = await db.query(
//       userTable,
//       limit: 1,
//       where: "email = ?",
//       whereArgs: [email.toLowerCase()],
//     );
//     if (queryResult.isNotEmpty) {
//       throw UserAlreadyExists();
//     }
//
//     final id = await db.insert(
//       userTable,
//       {emailColumn: email.toLowerCase()},
//     );
//
//     return DatabaseUser(id: id, email: email);
//   }
//
//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deleteCount = await db.delete(
//       userTable,
//       where: "email = ?",
//       whereArgs: [email.toLowerCase()],
//     );
//     if (deleteCount != 1) {
//       throw UnableToDeleteUser();
//     }
//   }
//
//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseNotOpen();
//     } else {
//       return db;
//     }
//   }
//
//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {
//       //do nothing
//     }
//   }
//
//   Future<void> open() async {
//     if (_db != null) {
//       throw DatabaseAlreadyOpenException();
//     }
//     try {
//       final docPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       _db = db;
//       //create user table if not exists
//       await db.execute(createUserTable);
//
//       //create note table if not exists
//       await db.execute(createNoteTable);
//       await _cacheNotes();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentsDirectory();
//     }
//   }
//
//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseNotOpen();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }
// }
//
// class DatabaseUser {
//   final int id;
//   final String email;
//
//   const DatabaseUser({required this.id, required this.email});
//
//   DatabaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;
//
//   @override
//   String toString() => "Person id = $id , email = $email";
//
//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;
//
//   @override
//   int get hashCode => id.hashCode;
// }
//
// class DatabaseNote {
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;
//
//   DatabaseNote(
//       {required this.id,
//       required this.userId,
//       required this.text,
//       required this.isSyncedWithCloud});
//
//   DatabaseNote.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         userId = map[userIdColumn] as int,
//         text = map[textColumn] as String,
//         isSyncedWithCloud =
//             (map[isSyncWithCloudColumn] as int) == 1 ? true : false;
//
//   @override
//   String toString() =>
//       "Note ID = $id , user id = $userId , text = $text , isSyncedWithCloud $isSyncedWithCloud";
//
//   @override
//   bool operator ==(covariant DatabaseNote other) => id == other.id;
//
//   @override
//   int get hashCode => id.hashCode;
// }
//
// const dbName = 'notes.db';
// const userTable = 'user';
// const noteTable = 'note';
// const idColumn = 'id';
// const emailColumn = 'email';
// const userIdColumn = 'user_id';
// const textColumn = 'text';
// const isSyncWithCloudColumn = 'is_synced_with_cloud';
// const createUserTable = '''
//       CREATE TABLE IF NOT EXISTS "user" (
//         "id"	INTEGER NOT NULL,
//         "email"	TEXT NOT NULL UNIQUE,
//         PRIMARY KEY("id" AUTOINCREMENT)
//       );
//       ''';
// const createNoteTable = '''
//       CREATE TABLE IF NOT EXISTS "note" (
//         "id"	INTEGER NOT NULL,
//         "user_id"	INTEGER NOT NULL,
//         "text"	TEXT,
//         "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
//         FOREIGN KEY("user_id") REFERENCES "user"("id"),
//         PRIMARY KEY("id" AUTOINCREMENT)
//       );
//       ''';
