import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animatch/services/match.service.dart';

class MatchesListScreen extends StatelessWidget {
  MatchesListScreen({super.key});

  final MatchService matchService = MatchService();

  // --- PERUBAHAN 3: Dialog didesain ulang agar lebih modern ---
  void _showMatchDialog(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    final imageUrl = data['urlImage'] as String? ?? '';
    final isFavorite = data['isFavorite'] as bool? ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900], // Latar belakang gelap
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Sudut lebih bulat
          ),
          contentPadding: const EdgeInsets.all(0), // Hapus padding default
          content: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bagian Gambar
                SizedBox(
                  height: 350,
                  width: double.infinity,
                  child:
                      imageUrl.isNotEmpty
                          ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.white54,
                                  ),
                                ),
                          )
                          : const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.white54,
                            ),
                          ),
                ),
                // Bagian Tombol Aksi
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Tombol Hapus
                      TextButton.icon(
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Colors.red[400], // Warna ikon dan teks
                        ),
                        onPressed: () async {
                          // Konfirmasi sebelum hapus
                          final confirm =
                              await showDialog<bool>(
                                context: context,
                                builder:
                                    (ctx) => AlertDialog(
                                      backgroundColor: Colors.grey[850],
                                      title: const Text(
                                        'Confirm Deletion',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      content: const Text(
                                        'Are you sure you want to delete this match?',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed:
                                              () =>
                                                  Navigator.of(ctx).pop(false),
                                        ),
                                        TextButton(
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          onPressed:
                                              () => Navigator.of(ctx).pop(true),
                                        ),
                                      ],
                                    ),
                              ) ??
                              false;

                          if (confirm) {
                            await matchService.deleteMatch(docId);
                            Navigator.of(context).pop(); // Tutup dialog utama
                          }
                        },
                      ),
                      // Tombol Favorite
                      TextButton.icon(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                        ),
                        label: Text(isFavorite ? 'Unfavorite' : 'Favorite'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(
                            0xfff43f5e,
                          ), // Warna aksen
                        ),
                        onPressed: () async {
                          await matchService.updateFavorite(docId, !isFavorite);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- PERUBAHAN 1: Tema dan AppBar disesuaikan dengan MatchScreen ---
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        21,
        21,
        21,
      ), // Latar belakang gelap
      appBar: AppBar(
        title: const Text('My Matches'),
        backgroundColor: Colors.transparent, // AppBar transparan
        elevation: 0, // Hilangkan bayangan AppBar
        titleTextStyle: const TextStyle(
          color: Color(0xfff43f5e), // Warna aksen untuk judul
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: Color(0xfff43f5e),
        ), // Warna untuk tombol back
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: matchService.getMatchesStream(
          FirebaseAuth.instance.currentUser?.uid ?? '',
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'An error occurred.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No saved matches yet.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.7, // Sesuaikan rasio aspek
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>? ?? {};
              final imageUrl = data['urlImage'] as String? ?? '';
              final isFavorite = data['isFavorite'] as bool? ?? false;

              // --- PERUBAHAN 2: Desain Grid Item diubah menggunakan Stack ---
              return GestureDetector(
                onTap: () => _showMatchDialog(context, doc.id, data),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit:
                        StackFit
                            .expand, // Membuat Stack memenuhi seluruh area grid item
                    children: [
                      // Gambar sebagai latar belakang
                      if (imageUrl.isNotEmpty)
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.white54,
                                ),
                              ),
                        )
                      else
                        Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.white54,
                            ),
                          ),
                        ),

                      // Ikon favorite sebagai overlay di pojok kanan atas
                      if (isFavorite)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Color(0xfff43f5e),
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
