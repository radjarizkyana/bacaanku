import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bacaanku/views/main_navigation.dart';
import '../../viewmodels/auth_viewmodel.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthViewModel>().currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigation()),
              (route) => false,
            );
          },
        ),
        title: const Text('Pesanan Saya'),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user?.id) 
            .orderBy('createdAt', descending: true) 
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada riwayat pesanan.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order['dateString'] ?? 'Tanggal tidak diketahui',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            order['status'] ?? 'Berhasil',
                            style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      order['title'] ?? 'Buku Tidak Diketahui',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Metode: ${order['paymentMethod'] ?? '-'}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: Rp ${order['price']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFC107)),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('ID: ${order['invoiceId']}', style: const TextStyle(color: Colors.black87, fontSize: 12)),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}