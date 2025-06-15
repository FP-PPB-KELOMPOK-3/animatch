import 'package:animatch/services/user.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final UserService _userService = UserService();
  String _userName = 'Guest';
  String _userEmail = 'Loading...';
  String _initials = 'G';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userDoc = await _userService.getUserById(currentUser.uid);
      if (mounted && userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _userName = userData['fullName'] ?? 'No Name';
          _userEmail = userData['email'] ?? 'No Email';
          _initials =
              _userName.isNotEmpty
                  ? _userName
                      .trim()
                      .split(' ')
                      .map((l) => l.isNotEmpty ? l[0] : '')
                      .take(2)
                      .join()
                      .toUpperCase()
                  : 'U';
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _userName = 'Guest';
          _userEmail = '';
          _initials = 'G';
        });
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _logout() async {
    // Tutup drawer terlebih dahulu
    Navigator.of(context).pop();

    bool? confirmLogout = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1F1F1F),
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
            contentTextStyle: const TextStyle(color: Colors.white70),
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Color(0xfff43f5e)),
                ),
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
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1F1F1F),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          _buildDrawerItem(
            icon: Icons.how_to_vote_outlined,
            title: 'Match',
            onTap: () {
              // Navigasi ke halaman utama
              Navigator.pushReplacementNamed(context, 'home');
            },
          ),
          _buildDrawerItem(
            icon: Icons.my_library_books_outlined,
            title: 'My Matches',
            onTap: () {
              // Navigasi ke list match
              Navigator.pushReplacementNamed(context, 'match_list');
            },
          ),
          _buildDrawerItem(
            icon: Icons.person_outline,
            title: 'My Profile',
            onTap: () {
              // Navigasi ke halaman profil
              Navigator.pushReplacementNamed(context, 'account_detail');
            },
          ),
          const Divider(color: Colors.white24),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            fullColor: Color(0xfff43f5e),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(color: Color(0xFF1F1F1F)),
      accountName: Text(
        _userName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      accountEmail: Text(
        _userEmail,
        style: const TextStyle(color: Color(0xfff43f5e), fontSize: 14),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: const Color(0xfff43f5e),
        child:
            _isLoading
                ? const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                )
                : Text(
                  _initials,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? fullColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: fullColor ?? Colors.white70),
      title: Text(title, style: TextStyle(color: fullColor ?? Colors.white)),
      onTap: onTap,
    );
  }
}
