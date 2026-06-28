import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _noteTitleController = TextEditingController();
  final TextEditingController _noteContentController = TextEditingController();

  List<Map<String, dynamic>> notes = [];
  late String userId;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  Future<void> _getUserId() async {
    User? user = _auth.currentUser;
    if (user != null) {
      userId = user.uid;
      _fetchNotes(); // Fetch notes once the user ID is available
    } else {
      // If no user is signed in, navigate to login or show an appropriate message
      Navigator.pushReplacementNamed(context, '/login'); // Or any screen you want
    }
  }

  Future<void> _fetchNotes() async {
    try {
      final snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId) // Filter notes by userId
          .get();

      setState(() {
        notes = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'title': doc['title'],
                  'content': doc['content'],
                  'timestamp': doc['timestamp'],
                })
            .toList();
        notes.sort((a, b) => b['timestamp'].compareTo(a['timestamp'])); // Sort by timestamp
      });
    } catch (e) {
      debugPrint('Error fetching notes: $e');
    }
  }

  Future<void> _addNote() async {
    if (_noteTitleController.text.isEmpty || _noteContentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }

    try {
      await _firestore.collection('notes').add({
        'title': _noteTitleController.text,
        'content': _noteContentController.text,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'userId': userId, // Ensure the note is associated with the logged-in user
      });

      _noteTitleController.clear();
      _noteContentController.clear();
      _fetchNotes(); // Refresh the notes list after adding a new note

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note added successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error adding note: $e');
    }
  }

  Future<void> _deleteNote(String id) async {
    try {
      await _firestore.collection('notes').doc(id).delete();
      _fetchNotes(); // Refresh notes after deletion
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error deleting note: $e');
    }
  }

  Color _getNoteColor() {
    final random = Random();
    return random.nextBool()
        ? Colors.blue[100] ?? Colors.blue
        : Colors.green[100] ?? Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: notes.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_alt_outlined,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No notes available',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: _getNoteColor(),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              note['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              note['content'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 16,
                              ),
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _deleteNote(note['id']);
                                } else if (value == 'edit') {
                                  _showEditNoteDialog(note);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                            onTap: () => _viewNoteDetail(note),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showAddNoteDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Note'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _noteTitleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteContentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _noteTitleController.clear();
              _noteContentController.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addNote();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditNoteDialog(Map<String, dynamic> note) {
    _noteTitleController.text = note['title'];
    _noteContentController.text = note['content'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _noteTitleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteContentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _noteTitleController.clear();
              _noteContentController.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateNote(note['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateNote(String id) async {
    if (_noteTitleController.text.isEmpty || _noteContentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }

    try {
      await _firestore.collection('notes').doc(id).update({
        'title': _noteTitleController.text,
        'content': _noteContentController.text,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      _noteTitleController.clear();
      _noteContentController.clear();
      _fetchNotes(); // Refresh notes after updating

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note updated successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error updating note: $e');
    }
  }

  void _viewNoteDetail(Map<String, dynamic> note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note['title']),
        content: Text(note['content']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
