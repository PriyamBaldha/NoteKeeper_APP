import 'package:cloud_firestore/cloud_firestore.dart';

class CloudFirestoreHelper {
  CloudFirestoreHelper._();

  static final CloudFirestoreHelper cloudFirestoreHelper =
      CloudFirestoreHelper._();

  static final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  late CollectionReference notesRef;
  void connectWithNotesCollection() {
    notesRef = firebaseFirestore.collection('note-keeper');
  }

  Future<void> insertRecord({
    required String title,
    required String description,
    //required String date,
  }) async {
    connectWithNotesCollection();
    Map<String, dynamic> data = {
      'title': title,
      'description': description,
      // 'date': date,
    };
    await notesRef.add(data);
  }

  Stream<QuerySnapshot> selectRecord() {
    connectWithNotesCollection();
    return notesRef.snapshots();
  }

  Future<void> updateRecord({
    required Map<String, dynamic> updatedData,
    required String updatedId,
  }) async {
    connectWithNotesCollection();
    await notesRef.doc(updatedId).update(updatedData);
  }

  Future<void> deleteRecord({required String id}) async {
    connectWithNotesCollection();
    await notesRef.doc(id).delete();
  }
}
