class CloudStorageException implements Exception {
  const CloudStorageException();
}

//Create
class CouldNotCreateNoteException extends CloudStorageException {}
//Retrieve
class CouldNotGetAllNotesException extends CloudStorageException {}
//Update
class CouldNotUpdateNoteException extends CloudStorageException {}
//Delete
class CouldNotDeleteNoteException extends CloudStorageException {}
