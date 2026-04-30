import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bacaanku/widgets/custom_book_card.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Rak Buku Saya'),
          bottom: const TabBar(
            indicatorColor: Color(0xFFFFC107), 
            labelColor: Color(0xFFFFC107), 
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Semua'),
              Tab(text: 'Sedang Dibaca'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFirestoreGrid(),
            _buildFirestoreGrid(), // Bisa dimodifikasi logikanya nanti
            _buildFirestoreGrid(), // Bisa dimodifikasi logikanya nanti
          ],
        ),
      ),
    );
  }

  Widget _buildFirestoreGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('books').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final books = snapshot.data!.docs;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.60,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            var doc = books[index];
            return CustomBookCard(
              bookId: doc.id,
              title: doc['title'] ?? '',
              author: doc['author'] ?? '',
              imageUrl: doc['imageUrl'] ?? '',
            );
          },
        );
      },
    );
  }
}