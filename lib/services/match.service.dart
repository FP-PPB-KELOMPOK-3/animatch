import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- Import Firebase Auth

class MatchService {
  final CollectionReference matchesCollection = FirebaseFirestore.instance
      .collection('matches');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- PERUBAHAN PADA CREATE ---
  // Method ini sekarang secara otomatis mengambil userId dari pengguna yang login
  Future<void> addMatch(Map<String, dynamic> matchData) async {
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      print("Error: User not logged in. Cannot add match.");
      return; // Hentikan fungsi jika tidak ada user yang login
    }

    try {
      await matchesCollection.add({
        "isFavorite": matchData['isFavorite'] ?? false,
        "urlImage": matchData['urlImage'] ?? '',
        "userId":
            currentUser.uid, // <-- Otomatis menggunakan ID pengguna saat ini
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding match: $e");
    }
  }

  // --- PERUBAHAN PADA READ ---
  // Method ini sekarang menerima userId untuk memfilter data
  Stream<QuerySnapshot> getMatchesStream(String userId) {
    return matchesCollection
        .where('userId', isEqualTo: userId) // <-- KLAUSA FILTER UTAMA
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // UPDATE (Tidak perlu diubah)
  Future<void> updateFavorite(String docId, bool newValue) async {
    await matchesCollection.doc(docId).update({'isFavorite': newValue});
  }

  // DELETE (Tidak perlu diubah)
  Future<void> deleteMatch(String docId) async {
    await matchesCollection.doc(docId).delete();
  }
}
