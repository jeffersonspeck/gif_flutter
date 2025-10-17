import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// se precisar do modelo GiphyGif

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gif_flutter.db');

    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela de favoritos
    await db.execute('''
      CREATE TABLE favorites(
        id TEXT PRIMARY KEY,
        title TEXT,
        url TEXT
      )
    ''');

    // Tabela de histórico de busca
    await db.execute('''
      CREATE TABLE history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT,
        timestamp INTEGER
      )
    ''');

    // Tabela de preferências
    await db.execute('''
      CREATE TABLE preferences(
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  // ---------------- Favoritos ----------------
  Future<void> addFavorite(String id, String title, String url) async {
    final db = await database;
    await db.insert('favorites', {
      'id': id,
      'title': title,
      'url': url,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFavorite(String id) async {
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await database;
    return db.query('favorites');
  }

  Future<bool> isFavorite(String id) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  // ---------------- Histórico ----------------
  Future<void> addHistory(String query) async {
    final db = await database;
    await db.insert('history', {
      'query': query,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await database;
    return db.query('history', orderBy: 'timestamp DESC', limit: 20);
  }

  // ---------------- Preferências ----------------
  Future<void> setPreference(String key, String value) async {
    final db = await database;
    await db.insert('preferences', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getPreference(String key) async {
    final db = await database;
    final result = await db.query(
      'preferences',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isNotEmpty) return result.first['value'] as String;
    return null;
  }
}
