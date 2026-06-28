import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeDashboard(),
    );
  }
}

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  HomeDashboardState createState() => HomeDashboardState();
}

class HomeDashboardState extends State<HomeDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> habits = [];
  DateTime _selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser; // Get the current signed-in user
    if (_user != null) {
      _fetchHabits();
    }
  }

  Future<void> _fetchHabits() async {
    if (_user == null) return;

    try {
      final snapshot = await _firestore
          .collection('habits')
          .where('userId', isEqualTo: _user!.uid) // Fetch only habits for the signed-in user
          .where('date',
              isEqualTo: _selectedDate.toIso8601String().split('T')[0])
          .get();
      setState(() {
        habits = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['name'],
            'description': doc['description'],
            'progress': doc['progress'],
            'date': doc['date'],
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('Error fetching habits: $e');
    }
  }

  Future<void> _addHabit(String name, String description) async {
    if (_user == null) return;

    try {
      await _firestore.collection('habits').add({
        'userId': _user!.uid, // Add userId to associate habits with the signed-in user
        'name': name,
        'description': description,
        'progress': 0,
        'date': _selectedDate.toIso8601String().split('T')[0],
      });
      _fetchHabits();
    } catch (e) {
      debugPrint('Error adding habit: $e');
    }
  }

  Future<void> _updateProgress(String habitId, int newProgress) async {
    if (_user == null) return;

    try {
      await _firestore.collection('habits').doc(habitId).update({
        'progress': newProgress,
      });
      _fetchHabits();
    } catch (e) {
      debugPrint('Error updating progress: $e');
    }
  }

  Future<void> _deleteHabit(String habitId) async {
    if (_user == null) return;

    try {
      await _firestore.collection('habits').doc(habitId).delete();
      _fetchHabits();
    } catch (e) {
      debugPrint('Error deleting habit: $e');
    }
  }

void _showAddHabitDialog() {
  String name = '';

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add Habit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Habit Name'),
            onChanged: (value) => name = value,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (name.isNotEmpty) {
              _addHabit(name, ''); // Now only passing habit name
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}


  Color _getProgressColor(int progress) {
    if (progress <= 30) {
      return Colors.redAccent;
    } else if (progress <= 70) {
      return Colors.yellow.shade700;
    } else {
      return Colors.greenAccent.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      // Show a login screen if the user is not signed in
      return Scaffold(
        appBar: AppBar(title: const Text('Habit Tracker')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              // Implement login flow here
            },
            child: const Text('Sign In'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDate,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
              _fetchHabits();
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) =>
                  _buildHabitCard(habits[index], index),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        child: IconButton(
          icon: const Icon(Icons.analytics),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AnalyticsPage(habits: habits)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHabitCard(Map<String, dynamic> habit, int index) {
    final int progress = habit['progress'];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Stack(
          children: [
            // Background: progress color filling
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress / 100,
                  child: Container(
                    color: _getProgressColor(progress),
                  ),
                ),
              ),
            ),
            // Foreground: Habit details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit['name'],
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < (progress / 20).ceil()
                                  ? Icons.check
                                  : Icons.circle_outlined,
                              color: Colors.black,
                              size: 20,
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${habit['progress']}% Completed',
                          style: const TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.black),
                    onPressed: () {
                      if (progress < 100) {
                        _updateProgress(habit['id'], progress + 10);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.black),
                    onPressed: () => _deleteHabit(habit['id']),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnalyticsPage extends StatelessWidget {
  final List<Map<String, dynamic>> habits;

  const AnalyticsPage({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barChartData = habits
        .map((habit) {
          return BarChartGroupData(
            x: habits.indexOf(habit),
            barRods: [
              BarChartRodData(
                toY: habit['progress'].toDouble(),
                gradient: LinearGradient(
                  colors: [
                    habit['progress'] < 30
                        ? Colors.red
                        : habit['progress'] < 70
                            ? Colors.yellow
                            : Colors.green,
                    Colors.white,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 22,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        })
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Progress Analytics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            titlesData: FlTitlesData(show: true),
            borderData: FlBorderData(show: true),
            gridData: FlGridData(show: true),
            barGroups: barChartData,
          ),
        ),
      ),
    );
  }
}
