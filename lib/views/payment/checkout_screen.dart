import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'payment_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final String title;
  final String author;
  final String imageUrl;
  final int price;

  const CheckoutScreen({
    super.key,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.price,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'BCA Virtual Account';
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    
    try {
      final user = context.read<AuthViewModel>().currentUser;
      if (user == null) throw Exception("User belum login");

      // 1. Siapkan Data Nota Pesanan (Invoice)
      final orderData = {
        'userId': user.id,
        'invoiceId': 'INV-${DateTime.now().millisecondsSinceEpoch}',
        'title': widget.title,
        'price': widget.price,
        'paymentMethod': _selectedPaymentMethod,
        'status': 'Berhasil', // Dalam dunia nyata, ini menunggu callback dari Midtrans/Xendit
        'createdAt': FieldValue.serverTimestamp(), // Waktu server Firebase
        'dateString': "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}", // Format tanggal sederhana
      };

      // 2. CREATE: Simpan ke Firestore di koleksi 'orders'
      await FirebaseFirestore.instance.collection('orders').add(orderData);

      // 3. Navigasi ke Halaman Sukses
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PaymentSuccessScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('Checkout'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ringkasan Pesanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Container(
                    width: 60, height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      image: DecorationImage(
                        image: widget.imageUrl.startsWith('http') 
                            ? NetworkImage(widget.imageUrl) as ImageProvider
                            : AssetImage(widget.imageUrl.isEmpty ? 'assets/images/cover1.jpg' : widget.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(widget.author, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 12),
                        Text(
                          'Rp ${widget.price}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFFC107)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('Metode Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildPaymentOption('BCA Virtual Account', Icons.account_balance),
                  const Divider(height: 1),
                  _buildPaymentOption('GoPay', Icons.account_balance_wallet),
                  const Divider(height: 1),
                  _buildPaymentOption('DANA', Icons.account_balance_wallet),
                  const Divider(height: 1),
                  _buildPaymentOption('ShopeePay', Icons.account_balance_wallet),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Pembayaran', style: TextStyle(color: Colors.grey)),
                  Text('Rp ${widget.price}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isProcessing ? null : _processPayment,
                child: _isProcessing 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Text('Bayar Sekarang', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon) {
    return RadioListTile<String>(
      title: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      value: title,
      groupValue: _selectedPaymentMethod,
      activeColor: const Color(0xFFFFC107),
      onChanged: (String? value) {
        setState(() => _selectedPaymentMethod = value!);
      },
    );
  }
}