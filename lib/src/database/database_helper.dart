import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _db;
  Future<Database?> get db async {
    if (_db == null) {
      _db = await initialDb();
      return _db;
    } else {
      return _db;
    }
  }

  initialDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'flexify.db');
    Database myDb = await openDatabase(path,
        onCreate: _onCreate, version: 1, onUpgrade: _onUpgrade);
    return myDb;
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) {}

  _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE 'wallfavs' (
      'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      'wallurl' TEXT NOT NULL,
      'wallname' TEXT NOT NULL,
      'wallauthor' TEXT,
      'wallresolution' TEXT NOT NULL,
      'wallsize' INTEGER NOT NULL,
      'wallcategory' TEXT NOT NULL,
      'wallcolors' TEXT NOT NULL
    )
''');
  }

  selectData(String sql) async {
    Database? myDb = await db;
    List<Map<String, Object?>>? response = await myDb?.rawQuery(sql);
    return response;
  }

  insertData(String sql) async {
    Database? myDb = await db;
    int? response = await myDb?.rawInsert(sql);
    return response;
  }

  updateData(String sql) async {
    Database? myDb = await db;
    int? response = await myDb?.rawUpdate(sql);
    return response;
  }

  deleteData(String sql) async {
    Database? myDb = await db;
    int? response = await myDb?.rawDelete(sql);
    return response;
  }
}
