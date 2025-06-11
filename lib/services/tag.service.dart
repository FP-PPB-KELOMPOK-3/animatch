import 'package:cloud_firestore/cloud_firestore.dart';

class TagService {
  final CollectionReference tagsCollection = FirebaseFirestore.instance
      .collection('tags');

  // CREATE
  Future<void> addTag(Map<String, dynamic> tagData) async {
    try {
      await tagsCollection.add({
        "tagName": tagData['tagName'] ?? 'missing-tag',
        "blacklisted": false,
        "userId": tagData['userId'] ?? '',
        "createdAt": tagData['createdAt'] ?? FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding match: $e");
    }
  }

  // READ
  Stream<QuerySnapshot> getTagsStream() {
    return tagsCollection.orderBy('createdAt', descending: true).snapshots();
  }

  // UPDATE
  Future<void> blacklistTag(String tagName, bool blacklisted) async {
    try {
      final query =
          await tagsCollection.where('tagName', isEqualTo: tagName).get();

      for (var doc in query.docs) {
        await doc.reference.update({'blacklisted': blacklisted});
      }
    } catch (e) {
      print("Error updating tag: $e");
    }
  }

  // DELETE
  Future<void> deleteTag(String tagName) async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('tags')
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
