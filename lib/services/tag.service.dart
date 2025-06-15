import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TagService {
  final CollectionReference tagsCollection = FirebaseFirestore.instance
      .collection('tags');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // CREATE
  Future<void> addTag(Map<String, dynamic> tagData) async {
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      print("Error: User not logged in. Cannot add tags.");
      return; // Hentikan fungsi jika tidak ada user yang login
    }

    try {
      await tagsCollection.add({
        "tagName": tagData['tagName'] ?? 'missing-tag',
        "blacklisted": false,
        "userId": currentUser.uid,
        "createdAt": tagData['createdAt'] ?? FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding match: $e");
    }
  }

  // READ
  Stream<QuerySnapshot> getTagsStream() {
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      print("Error: User not logged in. Cannot read tags.");
      return Stream.empty(); // Hentikan stream jika tidak ada user yang login
    }

    return tagsCollection
        .where(
          'userId',
          isEqualTo: currentUser.uid,
        ) // Filter berdasarkan userId
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // UPDATE
  Future<void> blacklistTag(String tagName, bool blacklisted) async {
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      print("Error: User not logged in. Cannot read tags.");
      return;
    }

    try {
      final query =
          await tagsCollection
              .where('userId', isEqualTo: currentUser.uid)
              .where('tagName', isEqualTo: tagName)
              .get();

      for (var doc in query.docs) {
        await doc.reference.update({'blacklisted': blacklisted});
      }
    } catch (e) {
      print("Error updating tag: $e");
    }
  }

  // DELETE
  Future<void> deleteTag(String tagName) async {
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      print("Error: User not logged in. Cannot read tags.");
      return;
    }

    try {
      final query =
          await FirebaseFirestore.instance
              .collection('tags')
              .where('userId', isEqualTo: currentUser.uid)
              .where('tagName', isEqualTo: tagName)
              .get();

      for (var doc in query.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print("Error deleting tag: $e");
    }
  }
}
