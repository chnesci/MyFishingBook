import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fishing.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // This is just a placeholder table to avoid errors.
    // The main app logic uses Hive.
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE IF NOT EXISTS fishing_logs (
        id $idType,
        location $textType,
        latitude $doubleType,
        longitude $doubleType,
        date $textType,
        weather $textType,
        notes $textType,
        photoPath $textType,
        lure $textType,
        lurePhotoPath $textType,
        userId $textType
      )
    ''');
  }

  // Dummy method to close the database to avoid memory leaks
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}