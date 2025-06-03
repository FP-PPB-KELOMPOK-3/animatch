import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class SwipeScreen extends StatelessWidget {
  final List<Widget> cards = [
    Container(
      alignment: Alignment.center,
      color: Colors.blue,
      child: const Text(
        '1',
        style: TextStyle(fontSize: 32, color: Colors.white),
      ),
    ),
    Container(
      alignment: Alignment.center,
      color: Colors.red,
      child: const Text(
        '2',
        style: TextStyle(fontSize: 32, color: Colors.white),
      ),
    ),
    Container(
      alignment: Alignment.center,
      color: Colors.purple,
      child: const Text(
        '3',
        style: TextStyle(fontSize: 32, color: Colors.white),
      ),
    ),
  ];

  SwipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Swipe Cards'),
      ),
      body: Center(
        child: SizedBox(
          height: 400,
          child: CardSwiper(
            cardsCount: cards.length,
            numberOfCardsDisplayed: 1,
            isLoop: true,
            cardBuilder: (context, index, percentX, percentY) => cards[index],
            allowedSwipeDirection: const AllowedSwipeDirection.only(
              left: true,
              right: true,
            ),
            onSwipe: (oldIndex, currentIndex, direction) {
              if (direction == CardSwiperDirection.right) {
                debugPrint("$oldIndex: MASOK");
              } else if (direction == CardSwiperDirection.left) {
                debugPrint("$oldIndex: NOPE");
              }

              return true;
            },
          ),
        ),
      ),
    );
  }
}
