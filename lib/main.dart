import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:bacaanku/viewmodels/auth_viewmodel.dart'; // Import ViewModel
import 'package:bacaanku/views/auth/login_screen.dart'; // Sesuaikan path baru
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // 1. WAJIB DITAMBAHKAN: Memastikan binding Flutter siap sebelum inisialisasi native
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. WAJIB DITAMBAHKAN: Inisialisasi Firebase berdasarkan platform (Android/iOS)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // Membungkus aplikasi dengan MultiProvider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        // Jika nanti ada HomeViewModel, tambahkan di sini
      ],
      child: const BacaanKuApp(),
    ),
  );
}

class BacaanKuApp extends StatelessWidget {
  const BacaanKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BacaanKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        primaryColor: const Color(0xFFFFC107),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6D4C41),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      home: const LoginScreen(), 
    );
  }
}