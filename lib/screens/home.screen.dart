import 'package:animatch/screens/match.screen.dart';
import 'package:animatch/screens/match_list.screen.dart';
import 'package:animatch/screens/swipe.screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _goToScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(
                context,
                'account_detail',
              ); // Navigasi ke halaman profil
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _goToScreen(const MatchScreen()),
              child: const Text("Go to Match Screen"),
            ),

            ElevatedButton(
              onPressed: () => _goToScreen(MatchesListScreen()),
              child: const Text("Go to Matches List Screen"),
            ),

            ElevatedButton(
              onPressed: () => _goToScreen(SwipeScreen()),
              child: const Text("Go to Swipe Screen"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
