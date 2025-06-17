import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animatch/services/user.service.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  
  DateTime? _selectedBirthDate;
  String? _selectedGender;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorCode = "";

  void navigateLogin() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'login');
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak, must be at least 6 characters.';
      case 'invalid-email':
        return 'The email format is invalid.';
      default:
        return 'An error occurred, please try again.';
    }
  }

  void register() async {
    // Rely on the Form's validator for all fields
    if (!_formKey.currentState!.validate()) {
      // Also check for gender and birthdate if the initial validation passes
      // This is to trigger the error message display for them
       if (_selectedGender == null || _selectedBirthDate == null) {
         setState(() {
            // Set a generic error code to show a message if they are null
            if (_selectedGender == null) _errorCode = 'gender-not-selected';
            if (_selectedBirthDate == null) _errorCode = 'birthdate-not-selected';
         });
       }
       return;
    }


    setState(() {
      _isLoading = true;
      _errorCode = "";
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Pastikan user tidak null sebelum melanjutkan
      if (userCredential.user != null) {
        await UserService().createUser(
          uid: userCredential.user!.uid,
          fullName: _fullNameController.text.trim(),
          username: _usernameController.text.trim(),
          email: userCredential.user!.email!,
          birthDate: _selectedBirthDate!,
          gender: _selectedGender!,
        );
        
        if (mounted) {
           // Navigasi setelah berhasil menyimpan data
           navigateLogin();
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Registration successful! Please log in.'), backgroundColor: Colors.green),
           );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorCode = e.code;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/bg_fix.jpg',
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 48.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 21, 21, 21).withOpacity(0),
                      const Color.fromARGB(255, 21, 21, 21),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.15],
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'REGISTER',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xfff43f5e),
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _fullNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration(label: 'Full Name', prefixIcon: Icons.person_outline),
                        validator: (v) => v!.isEmpty ? 'Full name cannot be empty' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration(label: 'Username', prefixIcon: Icons.alternate_email),
                        validator: (v) => v!.isEmpty ? 'Username cannot be empty' : null,
                      ),
                      const SizedBox(height: 16),
                       TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: _buildInputDecoration(label: 'Email', prefixIcon: Icons.email_outlined),
                        validator: (v) {
                          if (v!.isEmpty) return 'Email cannot be empty';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Invalid email format';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.white),
                        obscureText: _obscurePassword,
                        decoration: _buildInputDecoration(
                          label: 'Password',
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) {
                          if (v!.isEmpty) return 'Password cannot be empty';
                          if (v.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Custom Birth Date and Gender Fields
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              decoration: _buildInputDecoration(
                                label: _selectedBirthDate == null ? 'Birth Date' : "${_selectedBirthDate!.toLocal()}".split(' ')[0],
                                prefixIcon: Icons.calendar_today_outlined,
                              ),
                              validator: (v) => _selectedBirthDate == null ? 'Please select a date' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              dropdownColor: const Color.fromARGB(255, 30, 30, 30),
                              style: const TextStyle(color: Colors.white),
                              decoration: _buildInputDecoration(label: 'Gender', prefixIcon: Icons.person_search_outlined),
                              items: ['Male', 'Female'].map((String value) {
                                return DropdownMenuItem<String>(value: value, child: Text(value));
                              }).toList(),
                              onChanged: (value) => setState(() {
                                _selectedGender = value;
                                _formKey.currentState?.validate(); // Re-validate
                              }),
                              validator: (v) => v == null ? 'Please select a gender' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_errorCode.isNotEmpty)
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                           margin: const EdgeInsets.only(bottom: 16),
                           decoration: BoxDecoration(
                            color: Colors.red[900]?.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                           ),
                           child: Text(
                             _errorCode.contains('selected') ? 'Please complete all fields' : _getErrorMessage(_errorCode),
                             style: TextStyle(color: Colors.red[100], fontSize: 14),
                             textAlign: TextAlign.center,
                           ),
                         ),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xfff43f5e),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                              : const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? ", style: TextStyle(color: Colors.grey)),
                          GestureDetector(
                            onTap: navigateLogin,
                            child: const Text('Log In', style: TextStyle(color: Color(0xfff43f5e), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String label, required IconData prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(prefixIcon, color: Colors.grey),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withOpacity(0.5))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red[700]!, width: 1)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red[700]!, width: 1.5)),
      filled: true,
      fillColor: Colors.black.withOpacity(0.3),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
