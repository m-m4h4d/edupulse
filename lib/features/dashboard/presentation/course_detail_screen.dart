import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  final String title;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    required this.title,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  List<Map<String, dynamic>> _lessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    final db = await DatabaseHelper.instance.database;
    final data = await db.rawQuery('''
      SELECT l.id, l.title, l.duration, COALESCE(lp.is_completed, 0) as is_completed
      FROM ${DatabaseHelper.tableLessons} l
      LEFT JOIN ${DatabaseHelper.tableLessonProgress} lp ON l.id = lp.lesson_id
      WHERE l.course_id = ?
      ORDER BY l.order_index ASC
    ''', [widget.courseId]);

    setState(() {
      _lessons = data;
      _isLoading = false;
    });
  }

  Future<void> _markComplete(String lessonId) async {
    final db = await DatabaseHelper.instance.database;
    
    // Insert or replace lesson progress
    await db.insert(
      DatabaseHelper.tableLessonProgress,
      {
        'lesson_id': lessonId,
        'is_completed': 1,
        'watched_seconds': 0, // Mock
      },
      conflictAlgorithm: null, // Depending on sqflite, replace might need raw query
    ).catchError((e) async {
       await db.update(
        DatabaseHelper.tableLessonProgress,
        {'is_completed': 1},
        where: 'lesson_id = ?',
        whereArgs: [lessonId]
      );
      return 1;
    });

    // Calculate overall progress
    final totalRes = await db.rawQuery('SELECT COUNT(*) as cnt FROM ${DatabaseHelper.tableLessons} WHERE course_id = ?', [widget.courseId]);
    final compRes = await db.rawQuery('''
      SELECT COUNT(*) as cnt 
      FROM ${DatabaseHelper.tableLessonProgress} lp
      JOIN ${DatabaseHelper.tableLessons} l ON lp.lesson_id = l.id
      WHERE l.course_id = ? AND lp.is_completed = 1
    ''', [widget.courseId]);

    final total = Sqflite.firstIntValue(totalRes) ?? 1;
    final comp = Sqflite.firstIntValue(compRes) ?? 0;
    final progress = total > 0 ? (comp / total) : 0.0;

    // Update enrollment
    await db.update(
      DatabaseHelper.tableEnrollments,
      {'progress_percent': progress},
      where: 'course_id = ?',
      whereArgs: [widget.courseId],
    );

    _loadLessons(); // Reload UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lessons.isEmpty
              ? const Center(child: Text('No lessons available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = _lessons[index];
                    final isComplete = lesson['is_completed'] == 1;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isComplete ? Colors.green : Colors.blueGrey,
                          child: Icon(
                            isComplete ? Icons.check : Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(lesson['title']),
                        subtitle: Text('${(lesson['duration'] / 60).toStringAsFixed(1)} mins'),
                        trailing: isComplete
                            ? const Text('Completed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                            : TextButton(
                                onPressed: () => _markComplete(lesson['id']),
                                child: const Text('Complete'),
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}
