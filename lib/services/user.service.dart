import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  // CREATE
  Future<void> createUser({
    required String uid,
    required String fullName,
    required String username,
    required String email,
    required DateTime birthDate,
    required String gender,
  }) async {
    final formattedBirthDate = DateFormat('dd-MM-yyyy').format(birthDate);
    await usersCollection.doc(uid).set({
      'fullName': fullName,
      'username': username,
      'email': email,
      'birthDate': formattedBirthDate,
      'gender': gender,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // READ
  Future<DocumentSnapshot> getUserById(String uid) async {
    return await usersCollection.doc(uid).get();
  }

  // UPDATE
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await usersCollection.doc(uid).update(data);
  }

  // DELETE
  Future<void> deleteUser(String uid) async {
    await usersCollection.doc(uid).delete();
  }
}