import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService firestoreService = FirestoreService();

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final labelController = TextEditingController();

  void logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, 'login');
  }

  void openNoteBox(
      {String? docId,
      String? existingTitle,
      String? existingContent,
      String? existingLabel}) {
    if (docId != null) {
      titleController.text = existingTitle ?? '';
      contentController.text = existingContent ?? '';
      labelController.text = existingLabel ?? '';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(docId == null ? "Add Note" : "Edit Note"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: "Content"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: "Label"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                titleController.clear();
                contentController.clear();
                labelController.clear();
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (docId == null) {
                  firestoreService.addNote(
                    titleController.text,
                    contentController.text,
                    labelController.text,
                  );
                } else {
                  firestoreService.updateNote(
                    docId,
                    titleController.text,
                    contentController.text,
                    labelController.text,
                  );
                }

                titleController.clear();
                contentController.clear();
                labelController.clear();

                Navigator.pop(context);
              },
              child: Text(docId == null ? "Create" : "Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = userSnapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text("Notes (${user.email})"),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: logout,
              )
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => openNoteBox(),
            child: const Icon(Icons.add),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getNotes(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final notes = snapshot.data!.docs;

              if (notes.isEmpty) {
                return const Center(child: Text("No notes yet"));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  final data = note.data() as Map<String, dynamic>;

                  String title = data['title'] ?? '';
                  String content = data['content'] ?? '';
                  String label = data['label'] ?? '';

                  Timestamp? tgl = data['tgl'];
                  String date = "";

                  if (tgl != null) {
                    DateTime d = tgl.toDate();
                    date = "${d.day}/${d.month}/${d.year}";
                  }

                  return Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Expanded(
                            child: Text(
                              content,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          Text(
                            label,
                            style: const TextStyle(color: Colors.blue),
                          ),

                          Text(
                            date,
                            style: const TextStyle(fontSize: 12),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  openNoteBox(
                                    docId: note.id,
                                    existingTitle: title,
                                    existingContent: content,
                                    existingLabel: label,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  firestoreService.deleteNote(note.id);
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}