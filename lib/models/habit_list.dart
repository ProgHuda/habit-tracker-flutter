import 'package:habit_tracker_app/models/habit.dart'; // Ensure the path is correct
class HabitList {
  final List<Habit> _habits = [];

  void addHabit(Habit habit) {
    _habits.add(habit);
  }

  List<Habit> get habits => _habits;

  void removeHabit(int index) {
    if (index >= 0 && index < _habits.length) {
      _habits.removeAt(index);
    }
  }
}
