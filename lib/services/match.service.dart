import 'package:cloud_firestore/cloud_firestore.dart';

class MatchService {
  final CollectionReference matchesCollection = FirebaseFirestore.instance
      .collection('matches');

  // CREATE
  Future<void> addMatch(Map<String, dynamic> matchData) async {
    try {
      await matchesCollection.add({
        "isFavorite": matchData['isFavorite'] ?? false,
        "urlImage": matchData['urlImage'] ?? '',
        "userId": matchData['userId'] ?? '',
        "createdAt": matchData['createdAt'] ?? FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding match: $e");
    }
  }

  // READ
  Stream<QuerySnapshot> getMatchesStream() {
    return matchesCollection.orderBy('createdAt', descending: true).snapshots();
  }

  // UPDATE

  // DELETE
}
