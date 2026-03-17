import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int counter = 4;

  void incrementCounter() {
    setState(() {
      counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My First App"),
        backgroundColor: Colors.amber[300],
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // 🔹 IMAGE
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            color: Colors.blue[100],
            child: Image.network(
              'https://images.unsplash.com/photo-1501004318641-b39e6451bec6',
              height: 200,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 20),

          // 🔹 QUESTION
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            color: Colors.pink[300],
            child: const Text("What image is that?"),
          ),

          const SizedBox(height: 20),

          // 🔹 MENU
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.amber[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                MenuItem(icon: Icons.fastfood, label: "Food"),
                MenuItem(icon: Icons.landscape, label: "Scenery"),
                MenuItem(icon: Icons.people, label: "People"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🔹 COUNTER BOX
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            color: Colors.blueGrey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Counter here: $counter"),
                GestureDetector(
                  onTap: incrementCounter,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.cyan[200],
                    child: const Text(
                      "+",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 MENU ITEM (REUSABLE)
class MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const MenuItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}