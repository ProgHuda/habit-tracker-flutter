import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MoodTrackingPage extends StatefulWidget {
  const MoodTrackingPage({super.key});

  @override
  State<MoodTrackingPage> createState() => _MoodTrackingPageState();
}

class _MoodTrackingPageState extends State<MoodTrackingPage> {
  final TextEditingController noteController = TextEditingController();
  String selectedMood = 'Happy'; // Default mood
  DateTime selectedDate = DateTime.now(); // Initially select today's date
  String? userId; // Variable to store the current user's UID

  final List<Map<String, String>> moods = [
    {'name': 'Happy', 'emoji': '😊'},
    {'name': 'Sad', 'emoji': '😢'},
    {'name': 'Angry', 'emoji': '😡'},
    {'name': 'Excited', 'emoji': '🤩'},
    {'name': 'Stressed', 'emoji': '😰'},
  ];

  List<Map<String, dynamic>> savedMoods = [];

  // Define colors for each mood
  final Map<String, Color> moodColors = {
    'Happy': Colors.yellow,
    'Sad': Colors.blue,
    'Angry': Colors.red,
    'Excited': Colors.orange,
    'Stressed': Colors.purple,
  };

  final CalendarFormat _calendarFormat = CalendarFormat.month;

  Future<void> fetchMoods() async {
    if (userId == null) return;
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('moods')
          .where('userId', isEqualTo: userId)
          .where(
              'date',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(DateTime(selectedDate.year,
                      selectedDate.month, selectedDate.day)))
          .where(
              'date',
              isLessThan: Timestamp.fromDate(
                  DateTime(selectedDate.year, selectedDate.month,
                          selectedDate.day)
                      .add(const Duration(days: 1))))
          .get();

      if (mounted) {
        setState(() {
          savedMoods = snapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    'mood': doc['mood'],
                    'note': doc['note'],
                    'date': (doc['date'] as Timestamp).toDate(),
                  })
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching saved moods: $e')),
        );
      }
    }
  }

  Future<void> saveMood() async {
    if (userId == null) return;
    try {
      await FirebaseFirestore.instance.collection('moods').add({
        'mood': selectedMood,
        'note': noteController.text,
        'date': Timestamp.now(),
        'userId': userId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mood saved successfully!')),
        );
        noteController.clear();
        fetchMoods();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving mood: $e')),
        );
      }
    }
  }

  Future<void> deleteMood(String moodId) async {
    try {
      await FirebaseFirestore.instance.collection('moods').doc(moodId).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mood deleted successfully!')),
        );
        fetchMoods();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting mood: $e')),
        );
      }
    }
  }

  void getUserId() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      fetchMoods();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not signed in')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracking'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'How are you feeling today?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Mood Selector with scaling
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: moods.map((mood) {
                            final moodName = mood['name']!;
                            final moodEmoji = mood['emoji']!;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedMood = moodName;
                                });
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                padding: const EdgeInsets.all(12),
                                width: screenWidth * 0.2,
                                decoration: BoxDecoration(
                                  color: selectedMood == moodName
                                      ? moodColors[moodName]
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      moodEmoji,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      moodName,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: selectedMood == moodName
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Calendar
                      TableCalendar(
                        focusedDay: selectedDate,
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) =>
                            isSameDay(selectedDate, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            selectedDate = selectedDay;
                          });
                          fetchMoods();
                        },
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Saved Moods Section
                      const Text(
                        'Saved Moods for Today:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      savedMoods.isEmpty
                          ? const Text('No moods saved for this day.')
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: savedMoods.length,
                              itemBuilder: (context, index) {
                                final moodEntry = savedMoods[index];
                                return Card(
                                  color: moodColors[moodEntry['mood']] ??
                                      Colors.grey,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Mood: ${moodEntry['mood']}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Note: ${moodEntry['note']}',
                                          style:
                                              const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () {
                                              deleteMood(moodEntry['id']);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                      const SizedBox(height: 20),
                      // Note TextField
                      const Text(
                        'Add a note (Optional)',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          hintText: 'Write something about your mood...',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.deepPurple),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Save Button
              ElevatedButton(
                onPressed: saveMood,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 12),
                  backgroundColor: moodColors[selectedMood],
                ),
                child: const Text(
                  'Save Mood',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
