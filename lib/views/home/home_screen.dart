import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bacaanku/views/home/category_detail_screen.dart';
import 'package:bacaanku/widgets/custom_book_card.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'package:bacaanku/views/home/search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final userName = authVM.currentUser?.name ?? 'Pembaca';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Halo, $userName! 👋'), 
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/images/banner.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Kategori: Buku Populer
            _buildSectionHeader(context, 'Buku Populer'),
            const SizedBox(height: 12),
            _buildFirestoreBookList(), // Panggil fungsi StreamBuilder
            
            const SizedBox(height: 24),

            // Kategori: Buku Terlaris
            _buildSectionHeader(context, 'Buku Terlaris'),
            const SizedBox(height: 12),
            _buildFirestoreBookList(), // Panggil fungsi StreamBuilder
          ],
        ),
      ),
    );
  }

  // Header Kategori
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CategoryDetailScreen(categoryName: title)),
            );
          },
          child: const Text('Lihat semua', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  // List Buku dari Firestore
  Widget _buildFirestoreBookList() {
    return SizedBox(
      height: 240, 
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('books').limit(5).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada buku di database', style: TextStyle(color: Colors.grey)));
          }

          final books = snapshot.data!.docs;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: books.length, 
            itemBuilder: (context, index) {
              var doc = books[index];
              return CustomBookCard(
                bookId: doc.id, // ID unik dari Firestore
                title: doc['title'] ?? 'Tanpa Judul',
                author: doc['author'] ?? 'Tanpa Penulis',
                imageUrl: doc['imageUrl'] ?? '',
              );
            },
          );
        },
      ),
    );
  }
}