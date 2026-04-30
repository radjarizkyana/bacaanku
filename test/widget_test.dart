// This is a basic Flutter widget test for BacaanKu App.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Pastikan import ini sesuai dengan nama package project Anda
import 'package:bacaanku/main.dart'; 

void main() {
  testWidgets('BacaanKuApp smoke test', (WidgetTester tester) async {
    // 1. Bangun aplikasi kita dan picu frame render.
    // Kita panggil BacaanKuApp(), bukan MyApp()
    await tester.pumpWidget(const BacaanKuApp());

    // Tunggu sejenak agar semua animasi/UI selesai dirender
    await tester.pumpAndSettle();

    // 2. Verifikasi sederhana: Pastikan aplikasi berjalan tanpa crash
    // Kita mencari teks 'BacaanKu' yang ada di AppBar HomeScreen kita
    expect(find.text('BacaanKu'), findsWidgets);

    // Pastikan tidak ada teks '0' dari aplikasi counter bawaan sebelumnya
    expect(find.text('0'), findsNothing);
  });
}