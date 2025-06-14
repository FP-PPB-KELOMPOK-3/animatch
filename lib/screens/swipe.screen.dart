import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class SwipeScreen extends StatelessWidget {
  SwipeScreen({super.key});

  final CardSwiperController controller = CardSwiperController();

  final List<Widget> cards = [
    _buildCard("One", Colors.pink),
    _buildCard("Two", Colors.blue),
    _buildCard("Three", Colors.green),
    _buildCard("Four", Colors.orange),
    _buildCard("Five", Colors.purple),
  ];

  static Widget _buildCard(String text, Color color) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: color,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 36, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swipe Cards'),
        backgroundColor: Colors.black87,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 450,
            child: CardSwiper(
              controller: controller,
              cardsCount: cards.length,
              numberOfCardsDisplayed: cards.length,
              isLoop: false,
              cardBuilder: (context, index, percentX, percentY) => cards[index],
              allowedSwipeDirection: const AllowedSwipeDirection.only(
                left: true,
                right: true,
              ),
              onSwipe: (oldIndex, currentIndex, direction) {
                debugPrint("Swiped $direction");
                return true;
              },
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 36),
                onPressed: () {
                  controller.swipe(CardSwiperDirection.left);
                },
              ),
              const SizedBox(width: 30),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green, size: 36),
                onPressed: () {
                  controller.swipe(CardSwiperDirection.right);
                },
              ),
              const SizedBox(width: 30),
              IconButton(
                icon: const Icon(Icons.undo, color: Colors.grey, size: 36),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
