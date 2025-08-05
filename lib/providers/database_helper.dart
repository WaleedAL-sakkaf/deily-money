import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;
import '../models/entry.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Ensure initialization of FFI for desktop platforms
    if (_isDesktopPlatform()) {
      // Initialize FFI
      sqfliteFfiInit();
      // Change the default factory
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'entries.db');

    return await openDatabase(
      path,
      version: 3, // زيادة رقم الإصدار إلى 3 للتحديث الجديد
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // إضافة دالة الترقية
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE entries(
        id TEXT PRIMARY KEY,
        item TEXT,
        totalAmount REAL,
        piecePrice REAL,
        percentage REAL,
        customerId INTEGER,
        customerName TEXT,
        customerCurrency TEXT,
        transportation REAL,
        dailyExchange REAL,
        date TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // إضافة العمود الجديد dailyExchange
      await db.execute('ALTER TABLE entries ADD COLUMN dailyExchange REAL');
    }

    if (oldVersion < 3) {
      // إضافة الأعمدة الجديدة للعميل وإزالة technicalIssues
      await db.execute('ALTER TABLE entries ADD COLUMN customerId INTEGER');
      await db.execute('ALTER TABLE entries ADD COLUMN customerName TEXT');
      await db.execute('ALTER TABLE entries ADD COLUMN customerCurrency TEXT');

      // ملاحظة: SQLite لا يدعم حذف الأعمدة بشكل مباشر
      // لذا سنتركها كما هي، والكود الجديد لن يستخدمها
    }
  }

  Future<void> insertEntry(Entry entry) async {
    final db = await database;
    await db.insert('entries', entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateEntry(Entry entry) async {
    final db = await database;
    await db.update('entries', entry.toMap(),
        where: 'id = ?', whereArgs: [entry.id]);
  }

  // Helper method to check if running on desktop
  bool _isDesktopPlatform() {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  Future<List<Entry>> getEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('entries');
    return List.generate(maps.length, (i) {
      return Entry.fromMap(maps[i]);
    });
  }

  Future<void> deleteEntry(String id) async {
    final db = await database;
    await db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }

  /// حذف جميع البيانات من قاعدة البيانات
  Future<void> deleteAllEntries() async {
    final db = await database;
    await db.delete('entries');
  }
}
