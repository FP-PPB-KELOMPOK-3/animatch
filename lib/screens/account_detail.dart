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
    setState(() => _isLoading = true);
    final userDoc = await _userService.getUserById(uid);
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      
      _originalFullName = userData['fullName'] ?? '';
      _originalUsername = userData['username'] ?? '';

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

  Future<void> _saveChanges(String newFullName, String newUsername) async {
    setState(() => _isLoading = true);

    Map<String, dynamic> updatedData = {
      'fullName': newFullName.trim(),
      'username': newUsername.trim(),
    };

    try {
      await _userService.updateUser(uid, updatedData);
      
      await _loadUserData(); 

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- FUNGSI BARU UNTUK MENGHAPUS AKUN ---
  Future<void> _deleteAccount() async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        contentTextStyle: const TextStyle(color: Colors.white70),
        title: const Text('Delete Account'),
        content: const Text('Are you sure? This action is permanent and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete != true) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Hapus data Firestore terlebih dahulu
        await _userService.deleteUser(currentUser.uid);
        // Hapus pengguna dari Authentication
        await currentUser.delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted successfully.'), backgroundColor: Colors.green),
          );
          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This operation is sensitive. Please log out and log back in to delete your account.'), backgroundColor: Colors.orange),
        );
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: ${e.message}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e'), backgroundColor: Colors.red),
      );
    } finally {
       if(mounted) {
        setState(() => _isLoading = false);
       }
    }
  }


  void _logout() async {
    bool? confirmLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        contentTextStyle: const TextStyle(color: Colors.white70),
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout', style: TextStyle(color: Color(0xfff43f5e))),
          ),
        ],
      ),
    );

    if (confirmLogout == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
      }
    }
  }
  
  void _showEditProfileSheet() {
    final sheetFormKey = GlobalKey<FormState>();
    final sheetFullNameController = TextEditingController(text: _originalFullName);
    final sheetUsernameController = TextEditingController(text: _originalUsername);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1F1F1F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24
          ),
          child: Form(
            key: sheetFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Edit Profile',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildInfoField(label: 'Full Name', controller: sheetFullNameController, icon: Icons.person_outline, isEditing: true),
                const SizedBox(height: 16),
                _buildInfoField(label: 'Username', controller: sheetUsernameController, icon: Icons.alternate_email, isEditing: true),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[400],
                          side: BorderSide(color: Colors.red[400]!),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (sheetFormKey.currentState!.validate()) {
                            Navigator.of(context).pop(); 
                            _saveChanges(sheetFullNameController.text, sheetUsernameController.text);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Save'),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
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
    if (_isLoading && _fullNameController.text.isEmpty) { 
      return const Scaffold(backgroundColor: Color(0xFF151515), body: Center(child: CircularProgressIndicator()));
    }

    if (FirebaseAuth.instance.currentUser == null) {
      return const Scaffold(backgroundColor: Color(0xFF151515), body: Center(child: Text('Please log in again.', style: TextStyle(color: Colors.white))));
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 21, 21, 21),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        titleTextStyle: const TextStyle(color: Color(0xfff43f5e), fontSize: 22, fontWeight: FontWeight.bold),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: _showEditProfileSheet),
          const SizedBox(width: 8),
        ],
        iconTheme: const IconThemeData(color: Color(0xfff43f5e)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 40),
                  _buildInfoSection(
                    title: 'Profile Information',
                    children: [
                      _buildInfoField(label: 'Full Name', controller: _fullNameController, icon: Icons.person_outline),
                      _buildInfoField(label: 'Username', controller: _usernameController, icon: Icons.alternate_email),
                      _buildInfoField(label: 'Email', controller: _emailController, icon: Icons.email_outlined),
                      _buildInfoField(label: 'Birth Date', controller: _birthDateController, icon: Icons.cake_outlined),
                      _buildInfoField(label: 'Gender', controller: _genderController, icon: Icons.person_search_outlined),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // PERUBAHAN UTAMA DI SINI
                  _buildButtonArea(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(color: Colors.black.withOpacity(0.5), child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
  
  Widget _buildProfileHeader() {
    String initials = _fullNameController.text.isNotEmpty
      ? _fullNameController.text.trim().split(' ').map((l) => l.isNotEmpty ? l[0] : '').take(2).join().toUpperCase()
      : 'U';
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: const Color(0xfff43f5e),
          child: Text(initials, style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        Text(
          _fullNameController.text,
          style: const TextStyle(color: Color(0xfff43f5e), fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '@${_usernameController.text}',
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildInfoSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0xfff43f5e), fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isEditing = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: isEditing,
        style: TextStyle(color: isEditing ? Colors.white : Colors.grey[400]),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey, size: 20),
          filled: true,
          fillColor: Colors.black.withOpacity(0.2),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xfff43f5e), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red[700]!, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xfff43f5e), width: 1.5),
          ),
        ),
        validator: (value) {
          if (isEditing && (value == null || value.isEmpty)) {
            return '$label cannot be empty';
          }
          return null;
        },
      ),
    );
  }

  // --- WIDGET AREA TOMBOL DIPERBARUI ---
  Widget _buildButtonArea() {
    return Row(
      children: [
        // Tombol Delete Account
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.delete_forever_outlined),
              label: const Text('Delete'),
              onPressed: _deleteAccount,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[400],
                side: BorderSide(color: Colors.grey[600]!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Tombol Logout
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
