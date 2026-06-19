import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // IMPORT FIRESTORE
import 'package:bacaanku/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 
  
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
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      UserModel newUser = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        phoneNumber: '', // Kosong saat baru daftar
      );

      await _firestore.collection('users').doc(newUser.id).set(newUser.toMap());

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

    final isCurrentlyFav = _currentUser!.favorites.contains(bookId);
    final updatedFavorites = List<String>.from(_currentUser!.favorites);

    if (isCurrentlyFav) {
      updatedFavorites.remove(bookId); // Unbookmark
    } else {
      updatedFavorites.add(bookId);    // Bookmark
    }

    _currentUser = UserModel(
      id: _currentUser!.id, 
      name: _currentUser!.name, 
      email: _currentUser!.email,
      phoneNumber: _currentUser!.phoneNumber,
      favorites: updatedFavorites,
    );
    
    notifyListeners(); 

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
    }
  }
  
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot doc = await _firestore.collection('users').doc(credential.user!.uid).get();

      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
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