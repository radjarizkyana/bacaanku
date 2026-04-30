import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bacaanku/views/auth/login_screen.dart';
import 'package:bacaanku/views/profile/edit_profile_screen.dart';
import 'package:bacaanku/views/profile/order_history_screen.dart';
import '../../viewmodels/auth_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil data user aktif
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header Profil
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFFFC107),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 15),
            
            // 2. Tampilkan Nama Dinamis
            Text(
              user?.name ?? 'Nama Tidak Diketahui',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            
            // 3. Tampilkan Email Dinamis
            Text(
              user?.email ?? 'email@domain.com',
              style: const TextStyle(color: Colors.grey),
            ),
            
            const SizedBox(height: 30),

            // Menu List
            _buildProfileMenu(Icons.person_outline, 'Ubah Profil', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
              }),
            _buildProfileMenu(Icons.shopping_bag_outlined, 'Pesanan Saya', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
              );
            }),
            _buildProfileMenu(Icons.help_outline, 'Bantuan', () {}),
            _buildProfileMenu(Icons.privacy_tip_outlined, 'Kebijakan Privasi', () {}),
            _buildProfileMenu(Icons.info_outline, 'Tentang Aplikasi', () {}),
            const Divider(),
            _buildProfileMenu(Icons.logout, 'Keluar', () {
              context.read<AuthViewModel>().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }, isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : Colors.black87),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}