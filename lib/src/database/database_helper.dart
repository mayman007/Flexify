import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// A helper class for managing the local SQLite database.
class DatabaseHelper {
  static Database? _db;

  /// Provides a singleton instance of the database.
  Future<Database?> get db async {
    if (_db == null) {
      _db = await initialDb();
      return _db;
    } else {
      return _db;
    }
  }

  /// Initializes the database, creating it if it doesn't exist.
  initialDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'flexify.db');
    Database myDb = await openDatabase(path,
        onCreate: _onCreate, version: 1, onUpgrade: _onUpgrade);
    return myDb;
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) {}

  /// Creates the database tables when the database is first created.
  _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE 'wallfavs' (
      'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      'wallurlhq' TEXT NOT NULL,
      'wallurlmid' TEXT NOT NULL,
      'wallurllow' TEXT NOT NULL,
      'wallname' TEXT NOT NULL,
      'wallauthor' TEXT,
      'wallresolution' TEXT NOT NULL,
      'wallsize' INTEGER NOT NULL,
      'wallcategory' TEXT NOT NULL,
      'wallcolors' TEXT NOT NULL
    )
''');
    await db.execute('''
    CREATE TABLE 'widgetfavs' (
      'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      'widgeturl' TEXT NOT NULL,
      'widgetname' TEXT NOT NULL,
      'widgetauthor' TEXT,
      'widgetcategory' TEXT NOT NULL
    )
''');
    await db.execute('''
    CREATE TABLE 'lockscreenfavs' (
      'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      'lockscreenurl' TEXT NOT NULL,
      'lockscreenname' TEXT NOT NULL,
      'lockscreeneauthor' TEXT,
      'lockscreencategory' TEXT
    )
''');
  }

  /// Executes a raw SELECT query.
  selectData(String sql) async {
    Database? myDb = await db;
    List<Map<String, Object?>>? response = await myDb?.rawQuery(sql);
    return response;
  }

  /// Executes a raw INSERT query.
  insertData(String sql) async {
    Database? myDb = await db;
    int? response = await myDb?.rawInsert(sql);
    return response;
  }

  /// Executes a raw UPDATE query.
  updateData(String sql) async {
    Database? myDb = await db;
    int? response = await myDb?.rawUpdate(sql);
    return response;
  }

  /// Executes a raw DELETE query.
  deleteData(String sql) async {
    Database? myDb = await db;
    int? response = await myDb?.rawDelete(sql);
    return response;
  }
}
