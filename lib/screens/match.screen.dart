import 'package:animatch/models/card_item.model.dart';
import 'package:animatch/models/tag_item.model.dart';
import 'package:animatch/services/match.service.dart';
import 'package:animatch/services/tag.service.dart';
import 'package:animatch/services/nekosia.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'dart:math' as math;

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
    _loadInitialData();
  }

  // Memuat data filter yang tersimpan, lalu memuat kartu
  Future<void> _loadInitialData() async {
    await _loadSelectedTags();
    _fetchCards();
  }

  // Mengambil daftar tag yang sudah dipilih dari service
  Future<void> _loadSelectedTags() async {
    final initialSelectedTags = await tagsService.getTagsStream().first;
    if (mounted) {
      setState(() {
        selectedTags =
            initialSelectedTags.docs.map((doc) {
              return TagItem(
                tagName: doc['tagName'],
                blacklisted: doc['blacklisted'] ?? false,
              );
            }).toList();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Mengambil data kartu dari API berdasarkan filter `selectedTags`
  void _fetchCards() {
    setState(() {
      _isLoading = true;
    });

    // Logika ini memilih service yang tepat berdasarkan state selectedTags
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
            if (response != null && response.imageUrls.isNotEmpty) {
              setState(() {
                // Mengubah objek API menjadi objek UI (CardItem)
                cards =
                    response.imageUrls.map((url) {
                      return CardItem(
                        imagePath: url,
                        description:
                            response.descriptions[response.imageUrls.indexOf(
                              url,
                            )],
                        tags: response.tags[response.imageUrls.indexOf(url)],
                      );
                    }).toList();
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

  /// Helper untuk membangun UI Chip
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

  /// Menampilkan bottom sheet untuk memilih dan mengelola filter tag
  void _showTagBottomSheet() async {
    final tagsResponse = await NekosiaService.getTags();
    final allTags = tagsResponse?.tags ?? [];

    await _loadSelectedTags(); // Selalu load state terbaru saat membuka sheet

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            String searchQuery = '';
            final availableTags =
                allTags.where((tag) {
                  final isNotSelected =
                      !selectedTags.any((selected) => selected.tagName == tag);
                  if (searchQuery.isEmpty) return isNotSelected;
                  return isNotSelected &&
                      tag.toLowerCase().contains(searchQuery.toLowerCase());
                }).toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Selected Tags",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      // "Tap to blacklist, long press to remove.",
                      "Long press to remove.",
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    selectedTags.isEmpty
                        ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            "No tags selected yet.",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        )
                        : Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children:
                              selectedTags.map((tag) {
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      tag.blacklisted = !tag.blacklisted;
                                      tagsService.blacklistTag(
                                        tag.tagName,
                                        tag.blacklisted,
                                      );
                                    });
                                  },
                                  onLongPress: () {
                                    setModalState(() {
                                      tagsService.deleteTag(tag.tagName);
                                      selectedTags.remove(tag);
                                    });
                                  },
                                  child: Chip(
                                    label: Text(tag.tagName),
                                    backgroundColor:
                                        tag.blacklisted
                                            ? Colors.red[700]
                                            : const Color(0xfff43f5e),
                                    labelStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                    const SizedBox(height: 24),
                    TextField(
                      onChanged:
                          (value) => setModalState(() => searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search for tags to add...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child:
                          availableTags.isEmpty
                              ? Center(
                                child: Text(
                                  "No more tags to show or not found.",
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              )
                              : ListView.builder(
                                shrinkWrap: true,
                                itemCount: availableTags.length,
                                itemBuilder: (context, index) {
                                  final tag = availableTags[index];
                                  return ListTile(
                                    title: Text(
                                      tag,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    onTap: () {
                                      setModalState(() {
                                        final newTag = TagItem(tagName: tag);
                                        selectedTags.add(newTag);
                                        tagsService.addTag({
                                          'tagName': newTag.tagName,
                                          'userId': '',
                                          'blacklisted': newTag.blacklisted,
                                          'createdAt': DateTime.now(),
                                        });
                                      });
                                    },
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      debugPrint("Applying filters...");
      _fetchCards();
    });
  }

  /// Widget yang ditampilkan saat kartu habis atau tidak ada
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
            onPressed: _fetchCards,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xfff43f5e),
              foregroundColor: Colors.white,
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
                      : cards.isEmpty
                      ? _buildEmptyState()
                      : CardSwiper(
                        isLoop: false,
                        controller: _controller,
                        cardsCount: cards.length,
                        onSwipe: _onSwipe,
                        onEnd: () {
                          setState(() => cards.clear());
                        },
                        numberOfCardsDisplayed: math.min(3, cards.length),
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
                                      Text(
                                        card.description,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8.0,
                                        runSpacing: 8.0,
                                        children:
                                            card.tags.map((tag) {
                                              return _buildTagChip(
                                                tag,
                                                Colors.white.withOpacity(0.2),
                                              );
                                            }).toList(),
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
          ],
        ),
      ),
    );
  }

  /// Dipanggil setiap kali kartu di-swipe
  bool _onSwipe(
    int previousIndex,
    int? newIndex,
    CardSwiperDirection direction,
  ) {
    if (previousIndex >= cards.length) return false; // Pengaman
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
