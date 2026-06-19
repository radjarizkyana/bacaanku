import 'package:flutter/material.dart';
import '../main_navigation.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  // 1. DEKLARASI CONTROLLER
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buat Akun Baru 🚀',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Daftar sekarang untuk mulai menyimpan dan membaca buku favoritmu.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 40),

                // Input Nama Lengkap
                TextFormField(
                  controller: _nameController, // PASANG CONTROLLER
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 20),

                // Input Email
                TextFormField(
                  controller: _emailController, // PASANG CONTROLLER
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
                    if (!value.contains('@')) return 'Gunakan format email yang valid';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Input Password
                TextFormField(
                  controller: _passwordController, // PASANG CONTROLLER
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
                    if (value.length < 6) return 'Password minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Tombol Daftar
                Consumer<AuthViewModel>(
                  builder: (context, authVM, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: authVM.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                // 1. Kirim data ke Firebase
                                String? errorMessage = await authVM.register(
                                  _nameController.text.trim(),
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );

                                if (errorMessage == null || errorMessage.contains('email-already-in-use')) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const MainNavigation()),
                                    (route) => false,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Gagal: $errorMessage'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                        child: authVM.isLoading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text(
                                'Daftar Sekarang',
                                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}