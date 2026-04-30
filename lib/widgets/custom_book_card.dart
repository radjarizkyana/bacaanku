import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../views/book_detail/book_detail_screen.dart'; 
import '../../viewmodels/auth_viewmodel.dart';

class CustomBookCard extends StatelessWidget {
  final String bookId; 
  final String title;
  final String author;
  final String imageUrl;

  const CustomBookCard({
    super.key, 
    required this.bookId, 
    required this.title, 
    required this.author, 
    required this.imageUrl
  });

  Widget _buildImage() {
    // Menghapus fixed width/height agar gambar bersifat responsif (fluid)
    if (imageUrl.startsWith('http')) {
      return Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity);
    } else {
      String safeImage = imageUrl.isEmpty ? 'assets/images/cover1.jpg' : imageUrl;
      return Image.asset(safeImage, fit: BoxFit.cover, width: double.infinity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailScreen(
              bookId: bookId, title: title, author: author, imageUrl: imageUrl,
            ),
          ),
        );
      },
      child: Container(
        width: 140, // Sedikit diperlebar agar tidak terlalu sempit
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. RAHASIA ANTI-OVERFLOW: Gambar dibungkus Expanded
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: _buildImage(),
              ),
            ),
            
            // 2. Teks Info Buku (Sangat Compact)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            // 3. Posisi Tombol Bookmark (Menempel di kanan bawah)
            Padding(
              padding: const EdgeInsets.only(right: 6, bottom: 6),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Consumer<AuthViewModel>(
                  builder: (context, authVM, _) {
                    bool isFav = authVM.currentUser?.favorites.contains(bookId) ?? false;
                    return IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(), // Menghilangkan padding bawaan tombol
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border, 
                        color: Colors.red,
                        size: 22,
                      ),
                      onPressed: () => authVM.toggleFavorite(bookId),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}