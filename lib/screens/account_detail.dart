import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountDetail extends StatefulWidget {
  const AccountDetail({super.key});

  @override
  State<AccountDetail> createState() => _AccountDetailState();
}

class _AccountDetailState extends State<AccountDetail> {
  bool _isEditing = false;
  final _usernameController = TextEditingController();
  final _birthdateController = TextEditingController();
  String? _gender;

  void logout(context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
  }

  void saveProfile(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'username': _usernameController.text,
      'birthdate': _birthdateController.text,
      'gender': _gender ?? '',
    });
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!.data() as Map<String, dynamic>?;

        if (data == null) {
          return const Center(child: Text('No profile data found.'));
        }

        if (!_isEditing) {
          _usernameController.text = data['username'] ?? '';
          _birthdateController.text = data['birthdate'] ?? '';
          _gender = data['gender'];
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Account Information'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(_isEditing ? Icons.save : Icons.edit),
                onPressed: () {
                  if (_isEditing) {
                    saveProfile(user.uid);
                  } else {
                    setState(() {
                      _isEditing = true;
                    });
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => logout(context),
              ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(label: Text('Username')),
                    enabled: _isEditing,
                  ),
                  TextField(
                    controller: _birthdateController,
                    decoration: const InputDecoration(label: Text('Tanggal Lahir')),
                    enabled: _isEditing,
                  ),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    items: const [
                      DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                      DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                    ],
                    onChanged: _isEditing ? (val) => setState(() => _gender = val) : null,
                    decoration: const InputDecoration(label: Text('Jenis Kelamin')),
                  ),
                  const SizedBox(height: 16),
                  Text('Email: ${data['email'] ?? user.email}'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}