import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  List<Map<String, dynamic>> _enrollments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    final db = await DatabaseHelper.instance.database;
    // Join courses and enrollments
    final data = await db.rawQuery('''
      SELECT c.title, c.description, e.progress_percent 
      FROM ${DatabaseHelper.tableEnrollments} e
      JOIN ${DatabaseHelper.tableCourses} c ON e.course_id = c.id
    ''');
    
    setState(() {
      _enrollments = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _enrollments.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _enrollments.length,
                  itemBuilder: (context, index) {
                    final item = _enrollments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        leading: const Icon(Icons.play_circle_fill, size: 40, color: Colors.blue),
                        title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text('Progress: ${(item['progress_percent'] * 100).toInt()}%'),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: item['progress_percent'],
                              backgroundColor: Colors.grey[300],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No courses enrolled yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          const Text('Head to the Home tab to explore courses.'),
        ],
      ),
    );
  }
}
