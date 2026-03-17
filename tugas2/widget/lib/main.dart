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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My first app"),
        backgroundColor: Colors.amber[300],
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // 🔹 IMAGE CONTAINER
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            color: Colors.blue[100],
            child: Image.network(
              'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
              height: 200,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 20),

          // 🔹 QUESTION BOX
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            color: Colors.pink[200],
            child: const Text(
              "What image is that?",
              style: TextStyle(fontSize: 16),
            ),
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
                MenuItem(icon: Icons.person, label: "People"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 REUSABLE MENU ITEM
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