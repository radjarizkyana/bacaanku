import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_book_card.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final favList = authVM.currentUser?.favorites ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Buku Favorit Saya')),
      body: favList.isEmpty 
        ? _buildEmptyState()
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('books').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) return _buildEmptyState();

              // Filter hanya buku yang ID-nya ada di favList milik user
              final favBooks = snapshot.data!.docs.where((doc) => favList.contains(doc.id)).toList();

              if (favBooks.isEmpty) return _buildEmptyState();

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.60,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: favBooks.length,
                itemBuilder: (context, index) {
                  var doc = favBooks[index];
                  return CustomBookCard(
                    bookId: doc.id,
                    title: doc['title'] ?? '',
                    author: doc['author'] ?? '',
                    imageUrl: doc['imageUrl'] ?? '',
                  );
                },
              );
            },
          ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Belum ada buku di Rak Favorit', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}