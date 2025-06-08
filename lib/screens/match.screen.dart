import 'package:animatch/models/card_item.model.dart';
import 'package:animatch/services/match.service.dart';
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

  List<CardItem> cards = [];
  int swiperKey = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Match Screen'),
      ),
      body: Center(
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
                        cardBuilder: (context, index, percentX, percentY) {
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
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
                        allowedSwipeDirection: const AllowedSwipeDirection.only(
                          left: true,
                          right: true,
                        ),
                        onSwipe: (oldIndex, newIndex, direction) async {
                          final card = cards[oldIndex];
                          // final userId = FirebaseAuth.instance.currentUser?.uid;

                          if (direction == CardSwiperDirection.right) {
                            debugPrint("$oldIndex: MASOK");

                            try {
                              await matchService.addMatch({
                                // 'isFavorite': true,
                                'urlImage': card.imagePath,
                                // 'userId': userId,
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
                // getRandomAnimeImages
                NekosiaService.getRandomAnimeImages()
                    .then((response) {
                      if (response != null) {
                        // update the state to reflect the new images
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
                        debugPrint(
                          "cards content: ${cards.map((e) => e.imagePath).join(', ')}",
                        );
                        debugPrint(
                          "cards descriptions: ${cards.map((e) => e.description).join(', ')}",
                        );
                        debugPrint("cards length: ${cards.length}");
                      } else {
                        debugPrint("Failed to fetch images");
                      }
                    })
                    .catchError((error) {
                      debugPrint("Error fetching images: $error");
                    });
              },
              child: const Text("Start Matching"),
            ),
          ],
        ),
      ),
    );
  }
}
