import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // IMPORT FIRESTORE
import 'package:bacaanku/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // MESIN DATABASE
  
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  // --- FUNGSI REGISTER (AUTH + FIRESTORE) ---
  Future<String?> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Buat Akun di Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // 2. Siapkan Objek User Baru
      UserModel newUser = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        phoneNumber: '', // Kosong saat baru daftar
      );

      // 3. SIMPAN KE CLOUD FIRESTORE (Koleksi 'users')
      await _firestore.collection('users').doc(newUser.id).set(newUser.toMap());

      // 4. Jadikan user aktif di aplikasi
      _currentUser = newUser;
      
      return null; // Sukses
      
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Terjadi kesalahan sistem: $e'; 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String bookId) async {
    if (_currentUser == null) return;

    // 1. Tentukan status buku saat ini (Apakah sudah di-bookmark atau belum?)
    final isCurrentlyFav = _currentUser!.favorites.contains(bookId);
    final updatedFavorites = List<String>.from(_currentUser!.favorites);

    // 2. OPTIMISTIC UPDATE: Ubah state lokal secara instan detik ini juga
    if (isCurrentlyFav) {
      updatedFavorites.remove(bookId); // Unbookmark
    } else {
      updatedFavorites.add(bookId);    // Bookmark
    }

    // Perbarui memori aplikasi secara langsung
    _currentUser = UserModel(
      id: _currentUser!.id, 
      name: _currentUser!.name, 
      email: _currentUser!.email,
      phoneNumber: _currentUser!.phoneNumber,
      favorites: updatedFavorites,
    );
    
    // SINKRONISASI INSTAN: UI akan langsung bereaksi tanpa menunggu Firebase!
    notifyListeners(); 

    // 3. Eksekusi ke Server (Firebase) di Latar Belakang
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(_currentUser!.id);
      
      if (isCurrentlyFav) {
        // Hapus dari server
        await docRef.set({'favorites': FieldValue.arrayRemove([bookId])}, SetOptions(merge: true));
      } else {
        // Tambah ke server
        await docRef.set({'favorites': FieldValue.arrayUnion([bookId])}, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint("Gagal sinkronisasi ke server: $e");
      // Opsional: Anda bisa menambahkan logika rollback di sini jika ternyata server menolak
    }
  }
  
  // --- FUNGSI LOGIN (AMBIL DATA DARI FIRESTORE) ---
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Verifikasi Email & Password
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. AMBIL DATA PROFIL DARI FIRESTORE
      DocumentSnapshot doc = await _firestore.collection('users').doc(credential.user!.uid).get();

      if (doc.exists) {
        // Jika data profil ditemukan, masukkan ke memori aplikasi
        _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        // Jika data profil hilang di database (kasus langka), buat profil darurat
        _currentUser = UserModel(id: credential.user!.uid, name: 'Pembaca', email: email);
      }

      return null; // Sukses
      
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Terjadi kesalahan sistem: $e'; 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateUser(String newName, String newPhone, String newEmail) {
    if (_currentUser != null) {
      _currentUser = UserModel(
        id: _currentUser!.id,
        name: newName,  
        email: newEmail,
        phoneNumber: newPhone,
        favorites: _currentUser!.favorites, // Tetap gunakan data lama
      );
      notifyListeners();
    }
  }

  // --- FUNGSI LOGOUT ---
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}