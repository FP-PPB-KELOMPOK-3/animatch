import 'package:animatch/models/card_item.model.dart';
import 'package:animatch/services/match.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final matchService = MatchService();

  final List<CardItem> cards = [
    CardItem(imagePath: 'assets/1.jpg', description: 'Gambar 1 - kucing lucu'),
    CardItem(imagePath: 'assets/2.jpg', description: 'Gambar 2 - pantai indah'),
    CardItem(
      imagePath: 'assets/3.jpg',
      description: 'Gambar 3 - gunung tinggi',
    ),
    CardItem(imagePath: 'assets/4.jpg', description: 'Gambar 4 - langit senja'),
    CardItem(imagePath: 'assets/5.jpg', description: 'Gambar 5 - bunga mekar'),
  ];

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
            const SizedBox(height: 20),
            const Text('This is the Match Screen'),

            SizedBox(
              height: 500,
              width: double.infinity,
              child: CardSwiper(
                cardsCount: cards.length,
                numberOfCardsDisplayed: 1,
                isLoop: true,
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
                      child: Image.asset(
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
                Navigator.pop(context);
              },
              child: const Text("Go Back"),
            ),
          ],
        ),
      ),
    );
  }
}
