import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ReaderScreen extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const ReaderScreen({
    super.key,
    required this.title,
    required this.pdfUrl,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
            tooltip: 'Lihat Daftar Isi',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              // Membuka UI untuk zoom (hanya berfungsi jika PDF mendukungnya)
            },
          ),
        ],
      ),
      // MENGGUNAKAN URL DINAMIS YANG DIKIRIM DARI DETAIL BUKU
      body: SfPdfViewer.network(
        widget.pdfUrl, 
        key: _pdfViewerKey,
        canShowScrollHead: true,
        canShowScrollStatus: true,
      ),
    );
  }
}