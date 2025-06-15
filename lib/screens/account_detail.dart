import 'package:animatch/services/user.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountDetail extends StatefulWidget {
  const AccountDetail({super.key});

  @override
  State<AccountDetail> createState() => _AccountDetailState();
}

class _AccountDetailState extends State<AccountDetail> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  late String uid;

  // Controllers untuk setiap field input
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  // Variabel untuk menyimpan data asli, untuk fungsi "Batal"
  String _originalFullName = '';
  String _originalUsername = '';

  bool _isLoading = true;
  bool _isEditing = false; // State untuk mengontrol mode edit

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      uid = currentUser.uid;
      _loadUserData();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    final userDoc = await _userService.getUserById(uid);
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      
      // Simpan data asli
      _originalFullName = userData['fullName'] ?? '';
      _originalUsername = userData['username'] ?? '';

      // Set nilai awal untuk controllers
      _fullNameController.text = _originalFullName;
      _usernameController.text = _originalUsername;
      _emailController.text = userData['email'] ?? '';
      _birthDateController.text = userData['birthDate'] ?? '';
      _genderController.text = userData['gender'] ?? '';
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menyimpan perubahan...')),
      );

      Map<String, dynamic> updatedData = {
        'fullName': _fullNameController.text,
        'username': _usernameController.text,
      };

      try {
        await _userService.updateUser(uid, updatedData);
        
        // Perbarui juga data asli setelah berhasil menyimpan
        _originalFullName = _fullNameController.text;
        _originalUsername = _usernameController.text;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelEditing() {
    setState(() {
      // Kembalikan nilai controller ke data asli
      _fullNameController.text = _originalFullName;
      _usernameController.text = _originalUsername;
      _isEditing = false;
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (FirebaseAuth.instance.currentUser == null) {
      return const Scaffold(body: Center(child: Text('Silakan login kembali.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Information'),
        // Tombol di AppBar dihapus dari sini
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextFormField(
                controller: _fullNameController,
                label: 'Full Name',
                validator: (value) =>
                    value!.isEmpty ? 'Nama lengkap tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _usernameController,
                label: 'Username',
                validator: (value) =>
                    value!.isEmpty ? 'Username tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                  controller: _emailController, label: 'Email', enabled: false),
              const SizedBox(height: 16),
              _buildTextFormField(
                  controller: _birthDateController,
                  label: 'Birth Date',
                  enabled: false),
              const SizedBox(height: 16),
              _buildTextFormField(
                  controller: _genderController, label: 'Gender', enabled: false),
              const SizedBox(height: 32),
              
              // --- Area Tombol yang Baru ---
              _buildButtonArea(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk membangun area tombol di bagian bawah
  Widget _buildButtonArea() {
    if (_isEditing) {
      // Tampilkan tombol "Simpan" dan "Batal" saat mode edit
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: _cancelEditing,
            child: const Text('Batal'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _saveChanges,
            child: const Text('Simpan'),
          ),
        ],
      );
    } else {
      // Tampilkan tombol "Edit" dan "Logout" saat mode lihat
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
            child: const Text('Edit Data'),
          ),
          const SizedBox(width: 16),
          OutlinedButton(
            onPressed: _logout,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: const Text('Logout'),
          ),
        ],
      );
    }
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing && enabled,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: !(_isEditing && enabled),
        fillColor: Colors.grey[200],
      ),
      validator: validator,
    );
  }
}