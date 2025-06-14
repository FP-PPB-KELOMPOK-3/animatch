import 'package:animatch/models/card_item.model.dart';
import 'package:animatch/models/tag_item.model.dart';
import 'package:animatch/services/match.service.dart';
import 'package:animatch/services/tag.service.dart';
import 'package:animatch/services/nekosia.service.dart';
// import 'package:animatch/widgets/tapablechip.widget.dart'; // Jika tidak dipakai bisa dihapus
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final CardSwiperController _controller = CardSwiperController();
  final matchService = MatchService();
  final tagsService = TagService();

  List<CardItem> cards = [];
  List<TagItem> selectedTags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCards();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _fetchCards() {
    setState(() {
      _isLoading = true;
    });

    final future =
        selectedTags.any((tag) => !tag.blacklisted)
            ? NekosiaService.getAnimeImagesByTags(
              selectedTags
                  .where((t) => !t.blacklisted)
                  .map((t) => t.tagName)
                  .toList(),
              selectedTags
                  .where((t) => t.blacklisted)
                  .map((t) => t.tagName)
                  .toList(),
            )
            : NekosiaService.getRandomAnimeImages();

    future
        .then((response) {
          if (mounted) {
            // Pastikan widget masih ada di tree
            if (response != null && response.imageUrls.isNotEmpty) {
              setState(() {
                cards = List.generate(
                  response.imageUrls.length,
                  (i) => CardItem(
                    imagePath: response.imageUrls[i],
                    description:
                        response.descriptions.isNotEmpty
                            ? response.descriptions[i]
                            : "Anime Character",
                  ),
                );
                _isLoading = false;
              });
            } else {
              setState(() {
                cards = [];
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("No images found with the selected tags."),
                ),
              );
            }
          }
        })
        .catchError((error) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          debugPrint("Error fetching cards: $error");
        });
  }

  Widget _buildTagChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // --- LANGKAH 1: FUNGSI INI TIDAK LAGI DIPERLUKAN ---
  // Widget _buildActionButtons() { ... }

  void _showTagBottomSheet() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            height: 300,
            child: Column(
              children: [
                const Text(
                  "Filter by Tags",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "UI untuk memilih tag akan ditampilkan di sini.",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _fetchCards();
                  },
                  child: const Text("Apply Filters"),
                ),
              ],
            ),
          ),
    );
  }

  // --- LANGKAH 2: BUAT WIDGET BARU UNTUK TAMPILAN KARTU HABIS ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "All cards have been swiped!",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text("Search Again"),
            onPressed: _fetchCards, // Panggil fungsi fetch untuk memuat ulang
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xfff43f5e), // Warna primer
              foregroundColor: Colors.white, // Warna teks
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 21, 21, 21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Animatch',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xfff43f5e),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showTagBottomSheet,
          ),
        ],
        iconTheme: const IconThemeData(color: Color(0xfff43f5e)),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      // --- LANGKAH 3: GANTI TAMPILAN KARTU KOSONG ---
                      : cards.isEmpty
                      ? _buildEmptyState() // Gunakan widget yang baru dibuat
                      : CardSwiper(
                        isLoop: false,
                        controller: _controller,
                        cardsCount: cards.length,
                        onSwipe: _onSwipe,
                        // --- LANGKAH 4: UPDATE onEnd CALLBACK ---
                        onEnd: () {
                          // Saat kartu habis, panggil setState untuk mengosongkan list
                          // Ini akan memicu build ulang dan menampilkan _buildEmptyState
                          setState(() {
                            cards.clear();
                          });
                          debugPrint(
                            "All cards swiped, showing refresh button.",
                          );
                        },
                        numberOfCardsDisplayed: 2,
                        backCardOffset: const Offset(0, 40),
                        padding: const EdgeInsets.only(top: 10),
                        cardBuilder: (context, index, percentX, percentY) {
                          final card = cards[index];
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  image: DecorationImage(
                                    image: NetworkImage(card.imagePath),
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: 200,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.9),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    40,
                                    0,
                                    40,
                                    40,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8.0,
                                        runSpacing: 8.0,
                                        children: [
                                          _buildTagChip(
                                            'Anime Fan',
                                            Colors.white.withOpacity(0.2),
                                          ),
                                          _buildTagChip(
                                            'Gamer',
                                            Colors.pink.withOpacity(0.3),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
            ),
            // --- LANGKAH 1: HAPUS PEMANGGILAN TOMBOL AKSI ---
            // if (!_isLoading && cards.isNotEmpty) _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  bool _onSwipe(
    int previousIndex,
    int? newIndex,
    CardSwiperDirection direction,
  ) {
    final card = cards[previousIndex];
    debugPrint('Swiped ${direction.name} on ${card.description}');
    if (direction == CardSwiperDirection.right) {
      matchService
          .addMatch({'urlImage': card.imagePath, 'createdAt': DateTime.now()})
          .then((_) => debugPrint("Match saved!"))
          .catchError((e) => debugPrint("Failed to save match: $e"));
    }
    return true;
  }
}
