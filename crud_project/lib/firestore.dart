import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  // create new note
  Future<void> addNote(String title, String content, String location, int jumlah) {
    return notes.add({
      'title': title,
      'content': content,
      'jumlah' : jumlah,
      'location': location,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  // fetch all notes
  Stream<QuerySnapshot> getNotes() {
    return notes.orderBy('createdAt', descending: true).snapshots();
  }

  // update note
  Future<void> updateNote(String id, String title, String content, String location, int jumlah) {
    return notes.doc(id).update({
      'title': title,
      'content': content,
      'location': location,
      'jumlah' : jumlah,
      'updatedAt': Timestamp.now(),
    });
  }

  // delete note
  Future<void> deleteNote(String id) {
    return notes.doc(id).delete();
  }

}