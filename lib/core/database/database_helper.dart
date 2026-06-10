import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "edupulse.db";
  static const _databaseVersion = 1;

  // Tables
  static const tableCourses = 'courses';
  static const tableLessons = 'lessons';
  static const tableEnrollments = 'enrollments';
  static const tableLessonProgress = 'lesson_progress';

  // Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Open the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    // 1. Courses Table
    await db.execute('''
      CREATE TABLE $tableCourses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT,
        difficulty TEXT,
        thumbnail_url TEXT,
        is_bookmarked INTEGER DEFAULT 0
      )
    ''');

    // 2. Lessons Table
    await db.execute('''
      CREATE TABLE $tableLessons (
        id TEXT PRIMARY KEY,
        course_id TEXT,
        title TEXT NOT NULL,
        video_url TEXT,
        duration INTEGER,
        order_index INTEGER,
        FOREIGN KEY (course_id) REFERENCES $tableCourses (id) ON DELETE CASCADE
      )
    ''');

    // 3. Enrollments Table
    await db.execute('''
      CREATE TABLE $tableEnrollments (
        course_id TEXT PRIMARY KEY,
        enrolled_at TEXT NOT NULL,
        progress_percent REAL DEFAULT 0.0,
        FOREIGN KEY (course_id) REFERENCES $tableCourses (id) ON DELETE CASCADE
      )
    ''');

    // 4. Lesson Progress Table
    await db.execute('''
      CREATE TABLE $tableLessonProgress (
        lesson_id TEXT PRIMARY KEY,
        is_completed INTEGER DEFAULT 0,
        watched_seconds INTEGER DEFAULT 0,
        FOREIGN KEY (lesson_id) REFERENCES $tableLessons (id) ON DELETE CASCADE
      )
    ''');

    await _insertMockData(db);
  }

  Future<void> _insertMockData(Database db) async {
    // Insert Mock Courses
    final courses = [
      {
        'id': 'c1',
        'title': 'Flutter Mastery',
        'description': 'Learn Flutter from scratch to advanced concepts.',
        'category': 'Development',
        'difficulty': 'Intermediate',
      },
      {
        'id': 'c2',
        'title': 'UI/UX Design Principles',
        'description': 'Master the art of creating beautiful interfaces.',
        'category': 'Design',
        'difficulty': 'Beginner',
      },
      {
        'id': 'c3',
        'title': 'Advanced State Management',
        'description': 'Deep dive into Riverpod and BLoC.',
        'category': 'Development',
        'difficulty': 'Advanced',
      }
    ];

    for (var c in courses) {
      await db.insert(tableCourses, c);
    }
  }

  // Helper methods for generic CRUD can be added here
  // For example:
  Future<int> insert(String table, Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<int> update(String table, Map<String, dynamic> row, String idColumn, String id) async {
    Database db = await instance.database;
    return await db.update(table, row, where: '$idColumn = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, String idColumn, String id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$idColumn = ?', whereArgs: [id]);
  }
}
