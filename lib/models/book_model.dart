class BookModel {
  final String id;
  final String title;
  final String author;
  final String imageUrl;

  BookModel({required this.id, required this.title, required this.author, required this.imageUrl});

  factory BookModel.fromFirestore(Map<String, dynamic> data, String id) {
    return BookModel(
      id: id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}