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

  // Controllers for each input field
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  // Variables to store original data for the "Cancel" function
  String _originalFullName = '';
  String _originalUsername = '';

  bool _isLoading = true;
  bool _isEditing = false; // State to control edit mode

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

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Map<String, dynamic> updatedData = {
        'fullName': _fullNameController.text.trim(),
        'username': _usernameController.text.trim(),
      };

      try {
        await _userService.updateUser(uid, updatedData);
        
        _originalFullName = _fullNameController.text;
        _originalUsername = _usernameController.text;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
        setState(() => _isEditing = false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _cancelEditing() {
    setState(() {
      _fullNameController.text = _originalFullName;
      _usernameController.text = _originalUsername;
      _isEditing = false;
    });
  }

  void _logout() async {
    // Show a confirmation dialog before logging out
    bool? confirmLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
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
    if (_isLoading && _fullNameController.text.isEmpty) { // Initial loading condition
      return const Scaffold(
        backgroundColor: Color(0xFF151515),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (FirebaseAuth.instance.currentUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF151515),
        body: Center(child: Text('Please log in again.', style: TextStyle(color: Colors.white)))
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 21, 21, 21),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Color(0xfff43f5e), fontSize: 22, fontWeight: FontWeight.bold),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => setState(() => _isEditing = true))
          else
            IconButton(icon: const Icon(Icons.close), onPressed: _cancelEditing),
          const SizedBox(width: 8), // Memberi sedikit jarak
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
                  // PERBAIKAN 2: Mengembalikan header profil
                  _buildProfileHeader(),
                  const SizedBox(height: 40),
                  // The sections are now combined
                  _buildInfoSection(
                    title: 'Profile Information',
                    children: [
                      _buildInfoField(label: 'Full Name', controller: _fullNameController, icon: Icons.person_outline),
                      _buildInfoField(label: 'Username', controller: _usernameController, icon: Icons.alternate_email),
                      _buildInfoField(label: 'Email', controller: _emailController, icon: Icons.email_outlined, editable: false),
                      _buildInfoField(label: 'Birth Date', controller: _birthDateController, icon: Icons.cake_outlined, editable: false),
                      _buildInfoField(label: 'Gender', controller: _genderController, icon: Icons.person_search_outlined, editable: false),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _buildButtonArea(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
  
  // Helper untuk Header Profil (dikembalikan)
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

  // Helper for info section
  Widget _buildInfoSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0xfff43f5e), fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  // Helper for each info field
  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool editable = true,
  }) {
    bool isEnabled = _isEditing && editable;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: isEnabled,
        style: TextStyle(color: isEnabled ? Colors.white : Colors.grey[400]),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey, size: 20),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.black.withOpacity(0.2),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xfff43f5e))),
          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.red[700]!)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.red[700]!)),
        ),
        validator: (value) {
          if (editable && (value == null || value.isEmpty)) {
            return '$label cannot be empty';
          }
          return null;
        },
      ),
    );
  }

  // Helper for button area
  Widget _buildButtonArea() {
    if (_isEditing) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.save_alt_outlined),
          label: const Text('Save Changes'),
          onPressed: _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
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
      );
    }
  }
}
