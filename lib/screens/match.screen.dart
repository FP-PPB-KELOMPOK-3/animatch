import 'package:animatch/models/card_item.model.dart';
import 'package:animatch/services/match.service.dart';
import 'package:animatch/services/tag.service.dart';
import 'package:animatch/services/nekosia.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final matchService = MatchService();
  final tagsService = TagService();

  List<CardItem> cards = [];
  List<String> selectedTags = [];
  int swiperKey = 0;

  bool _isBottomSheetOpen = false;

  void _showTagBottomSheet() async {
    if (_isBottomSheetOpen) return; // Prevent multiple modals
    _isBottomSheetOpen = true;

    final tagsResponse = await NekosiaService.getTags();
    final allTags = tagsResponse?.tags ?? [];
    final selectedTagsFuture =
        tagsService.getTagsStream().map((snapshot) {
          return snapshot.docs.map((doc) => doc['tagName'] as String).toList();
        }).first;
    selectedTags = await selectedTagsFuture;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String search = '';
        return FutureBuilder<List<String>>(
          future: selectedTagsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.35,
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Drag symbol
                          Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          // search field
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Add tags',
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (value) {
                              setModalState(() => search = value);
                            },
                          ),
                          const SizedBox(height: 12),
                          // Autocomplete suggestions as a vertical list
                          if (search.isNotEmpty)
                            Container(
                              constraints: BoxConstraints(
                                maxHeight: 200, // Adjust as needed
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: ListView(
                                shrinkWrap: true,
                                children:
                                    allTags
                                        .where(
                                          (tag) =>
                                              tag.toLowerCase().contains(
                                                search.toLowerCase(),
                                              ) &&
                                              !selectedTags.contains(tag),
                                        )
                                        .map(
                                          (tag) => ListTile(
                                            title: Text(tag),
                                            onTap: () {
                                              setModalState(() {
                                                selectedTags.add(tag);
                                                tagsService.addTag({
                                                  'tagName': tag,
                                                  'userId':
                                                      '', // Replace with actual user ID
                                                  'createdAt': DateTime.now(),
                                                });
                                                search =
                                                    ''; // Clear search after selection
                                              });
                                            },
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),
                          const SizedBox(height: 12),
                          // selected tags
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                selectedTags.map((tag) {
                                  return Chip(
                                    label: Text(tag),
                                    onDeleted: () {
                                      setModalState(() {
                                        selectedTags.remove(tag);
                                        tagsService.deleteTag(tag);
                                      });
                                    },
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );

    _isBottomSheetOpen = false; // Reset the flag when closed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Match Screen'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! < -5) {
            _showTagBottomSheet();
          }
        },
        child: Stack(
          children: [
            Center(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 500,
                    width: double.infinity,
                    child:
                        cards.isEmpty
                            ? const Center(
                              child: Text("Start matching to show cards"),
                            )
                            : CardSwiper(
                              key: ValueKey(swiperKey),
                              cardsCount: cards.length,
                              numberOfCardsDisplayed: 1,
                              isLoop: false,
                              cardBuilder: (
                                context,
                                index,
                                percentX,
                                percentY,
                              ) {
                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      cards[index].imagePath,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                              allowedSwipeDirection:
                                  const AllowedSwipeDirection.only(
                                    left: true,
                                    right: true,
                                  ),
                              onSwipe: (oldIndex, newIndex, direction) async {
                                final card = cards[oldIndex];
                                if (direction == CardSwiperDirection.right) {
                                  debugPrint("$oldIndex: MASOK");
                                  try {
                                    await matchService.addMatch({
                                      'urlImage': card.imagePath,
                                    });
                                    debugPrint("Match disimpan!");
                                  } catch (e) {
                                    debugPrint("Gagal menyimpan match: $e");
                                  }
                                }
                                return true;
                              },
                            ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedTags.isEmpty) {
                        debugPrint("No tags selected, fetching random images");
                        NekosiaService.getRandomAnimeImages().then((response) {
                          if (response != null) {
                            setState(() {
                              cards = List.generate(
                                response.imageUrls.length,
                                (i) => CardItem(
                                  imagePath: response.imageUrls[i],
                                  description: response.descriptions[i],
                                ),
                              );
                              swiperKey++;
                            });
                          }
                        });
                      } else {
                        debugPrint("Using selected tags: $selectedTags");
                        NekosiaService.getAnimeImagesByTags(selectedTags).then((
                          response,
                        ) {
                          if (response != null) {
                            setState(() {
                              cards = List.generate(
                                response.imageUrls.length,
                                (i) => CardItem(
                                  imagePath: response.imageUrls[i],
                                  description: response.descriptions[i],
                                ),
                              );
                              swiperKey++;
                            });
                          }
                        });
                      }
                    },
                    child: const Text("Start Matching"),
                  ),
                ],
              ),
            ),
            // Optionally, keep the visual drag handle at the bottom
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.keyboard_arrow_up,
                      size: 32,
                      color: Colors.grey,
                    ),
                    const Text(
                      "Swipe up to search tags",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
