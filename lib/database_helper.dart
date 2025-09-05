import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'liveapps.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sources (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        identifier TEXT,
        subtitle TEXT,
        sourceURL TEXT,
        iconURL TEXT,
        website TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE apps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source_id INTEGER,
        name TEXT,
        bundleIdentifier TEXT,
        version TEXT,
        versionDate TEXT,
        downloadURL TEXT,
        localizedDescription TEXT,
        iconURL TEXT,
        size INTEGER,
        FOREIGN KEY(source_id) REFERENCES sources(id)
      )
    ''');
  }

  Future<int> insertSource(Map<String, dynamic> source) async {
    final db = await database;
    return await db.insert('sources', source);
  }

  Future<int> deleteSource(int id) async {
    final db = await database;
    return await db.delete('sources', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertApp(Map<String, dynamic> app) async {
    final db = await database;
    return await db.insert('apps', app);
  }

  Future<List<Map<String, dynamic>>> getApps() async {
    final db = await database;
    return await db.query('apps', orderBy: 'versionDate DESC');
  }

  Future<List<Map<String, dynamic>>> getAppsBySource(int sourceId) async {
    final db = await database;
    return await db.query(
      'apps',
      where: 'source_id = ?',
      whereArgs: [sourceId],
      orderBy: 'versionDate DESC',
    );
  }

  Future<int> deleteAllApps() async {
    final db = await database;
    return await db.delete('apps');
  }
}
