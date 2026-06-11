import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '../../../core/database/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;
  String _quote = "Loading quote of the day...";
  String _author = "";

  String _searchQuery = '';
  String _selectedDifficulty = 'All';

  @override
  void initState() {
    super.initState();
    _fetchQuote();
    _loadCourses();
  }

  Future<void> _fetchQuote() async {
    try {
      final response = await http.get(Uri.parse('https://dummyjson.com/quotes/random'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _quote = data['quote'];
          _author = data['author'];
        });
      } else {
        setState(() => _quote = "Never stop learning!");
      }
    } catch (e) {
      setState(() => _quote = "Never stop learning!");
    }
  }

  Future<void> _loadCourses() async {
    final db = await DatabaseHelper.instance.database;
    
    String query = 'SELECT * FROM ${DatabaseHelper.tableCourses} WHERE title LIKE ?';
    List<dynamic> args = ['%$_searchQuery%'];

    if (_selectedDifficulty != 'All') {
      query += ' AND difficulty = ?';
      args.add(_selectedDifficulty);
    }

    final data = await db.rawQuery(query, args);
    setState(() {
      _courses = data;
      _isLoading = false;
    });
  }

  Future<void> _enrollCourse(String courseId) async {
    final db = await DatabaseHelper.instance.database;
    
    // Check if already enrolled
    final existing = await db.query(
      DatabaseHelper.tableEnrollments,
      where: 'course_id = ?',
      whereArgs: [courseId],
    );

    if (existing.isEmpty) {
      await db.insert(DatabaseHelper.tableEnrollments, {
        'course_id': courseId,
        'enrolled_at': DateTime.now().toIso8601String(),
        'progress_percent': 0.0,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully enrolled! Check My Courses.')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Already enrolled in this course.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb ? null : AppBar(
        title: const Text('EduPulse Dashboard'),
      ),
      body: Column(
        children: [
          // Quote Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Quote of the Day',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"$_quote"',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                    if (_author.isNotEmpty)
                      Text(
                        '- $_author',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),
          ),
          
          // Search & Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search courses...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                      _loadCourses();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedDifficulty,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    ),
                    items: ['All', 'Beginner', 'Intermediate', 'Advanced']
                        .map((diff) => DropdownMenuItem(
                              value: diff,
                              child: Text(diff),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedDifficulty = value);
                        _loadCourses();
                      }
                    },
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(),

          const SizedBox(height: 8),
          
          // Course List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _courses.isEmpty
                    ? const Center(child: Text('No courses found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _courses.length,
                        itemBuilder: (context, index) {
                          final course = _courses[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Hero(
                                        tag: 'course_icon_${course['id']}',
                                        child: const Icon(Icons.school, size: 40, color: Colors.blue),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              course['title'],
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              course['difficulty'],
                                              style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(course['description'] ?? ''),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => _enrollCourse(course['id']),
                                      child: const Text('Enroll Now'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate()
                           .fadeIn(delay: Duration(milliseconds: 300 + (100 * index)))
                           .slideX(begin: 0.1);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
