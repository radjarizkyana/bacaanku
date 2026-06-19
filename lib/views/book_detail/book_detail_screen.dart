import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bacaanku/views/payment/checkout_screen.dart';
import 'package:bacaanku/views/reader/reader_screen.dart';
import '../../viewmodels/auth_viewmodel.dart';

class BookDetailScreen extends StatelessWidget {
  final String bookId;
  final String title;
  final String author;
  final String imageUrl;

  const BookDetailScreen({
    super.key,
    required this.bookId,
    required this.title,
    required this.author,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // TOMBOL BOOKMARK DINAMIS
          Consumer<AuthViewModel>(
            builder: (context, authVM, _) {
              bool isFav = authVM.currentUser?.favorites.contains(bookId) ?? false;
              return IconButton(
                icon: Icon(
                  isFav ? Icons.bookmark : Icons.bookmark_border, 
                  color: isFav ? const Color(0xFFFFC107) : Colors.white, // Kuning jika favorit
                ),
                onPressed: () => authVM.toggleFavorite(bookId),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {}, // Aksi share
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Cover Buku
            Container(
              height: 250,
              width: 170,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5)),
                ],
                image: DecorationImage(
                  // Deteksi Cerdas Gambar
                  image: imageUrl.startsWith('http') 
                      ? NetworkImage(imageUrl) as ImageProvider
                      : AssetImage(imageUrl.isEmpty ? 'assets/images/cover1.jpg' : imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(author, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // Navigasi dengan mengirimkan PDF sungguhan
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (_) => ReaderScreen(
                      title: title,
                      // Ini adalah PDF sungguhan setebal 140 halaman
                      pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf', 
                    )
                  )
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: const BorderSide(color: const Color(0xFFFFC107)),
              ),
              child: const Text('Baca Sampel', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen(
                title: title, author: author, imageUrl: imageUrl, price: 85000,
              ))),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
              ),
              child: const Text('Beli Buku', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
  }