class Habit {
  int? id; // Add the id field
  final String name;
  final String description;
  final double progress;

  Habit({
    this.id, // id is optional for new habits
    required this.name,
    required this.description,
    this.progress = 0,
  });

  // Convert a Habit object into a Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'progress': progress,
    };
  }

  // Convert a Map into a Habit object for SQLite
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      progress: map['progress'],
    );
  }
}
