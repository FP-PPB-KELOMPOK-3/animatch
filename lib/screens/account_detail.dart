import 'package:animatch/Auth/login.dart';
import 'package:animatch/services/user.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



class AccountDetail extends StatelessWidget {
  const AccountDetail({super.key});

  void logout(context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
  }

@override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const LoginScreen();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: UserService().getUserById(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text('User data not found')));
        }
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        return Scaffold(
          appBar: AppBar(title: const Text('Account Information')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Full Name: ${userData['fullName']}'),
                Text('Username: ${userData['username']}'),
                Text('Email: ${userData['email']}'),
                Text('Birth Date: ${userData['birthDate']}'),
                Text('Gender: ${userData['gender']}'),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => logout(context),
                  child: const Text('Logout'),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}