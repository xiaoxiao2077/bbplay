import 'dart:io';
import '/utils/loggy.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static late Database dbh;
  static const int version = 1;
  static const String dbname = 'bbplay.db';

  static Future<Database> initialize() async {
    Directory databaseDirectory;
    databaseDirectory = await getApplicationSupportDirectory();
    String path = join(databaseDirectory.path, dbname);
    Loggy.i("db path: $path");
    dbh = await openDatabase(
      path,
      version: version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return dbh;
  }

  // 创建表
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS history  (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        bvid TEXT NOT NULL,
        cid INTEGER NOT NULL,
        cover TEXT NOT NULL,
        duration INTEGER NOT NULL,
        seek INTEGER DEFAULT 0,
        author TEXT NOT NULL,
        page INTEGER DEFAULT 1,
        is_liked INTEGER DEFAULT 0,
        is_collected INTEGER DEFAULT 0,
        created TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
        updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
      )
    ''');
    await db.execute('''CREATE INDEX history_time ON history (created DESC)''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS favorite (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        bvid TEXT NOT NULL,
        cid INTEGER NOT NULL,
        cover TEXT NOT NULL,
        duration INTEGER NOT NULL,
        author TEXT NOT NULL,
        created TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS wall_clock (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        weekday INTEGER NOT NULL,
        elapsed INTEGER NOT NULL DEFAULT 1,
        updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS timeslot (
        weekday INTEGER NOT NULL PRIMARY KEY,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        duration INTEGER NOT NULL,
        enabled INTEGER NOT NULL DEFAULT 1,
        updated INTEGER DEFAULT 0
      )
    ''');

    db.execute(
        '''INSERT INTO timeslot (weekday, start_time, end_time, duration, enabled) 
      VALUES (1, "17:00", "21:00", 1440, 1)''');
    db.execute(
        '''INSERT INTO timeslot (weekday, start_time, end_time, duration, enabled) 
      VALUES (2, "17:00", "21:00", 1440, 1)''');
    db.execute(
        '''INSERT INTO timeslot (weekday, start_time, end_time, duration, enabled) 
      VALUES (3, "17:00", "21:00", 1440, 1)''');
    db.execute(
        '''INSERT INTO timeslot (weekday, start_time, end_time, duration, enabled) 
      VALUES (4, "17:00", "21:00", 1440, 1)''');
    db.execute(
        '''INSERT INTO timeslot (weekday, start_time, end_time, duration, enabled) 
      VALUES (5, "17:00", "21:00", 1440, 1)''');
    db.execute(
        '''INSERT INTO timeslot (weekday, start_time, end_time, duration, enabled) 
      VALUES (6, "8:30", "21:00", 1440, 1)''');
    db.execute(
        '''INSERT INTO timeslot (weekday, start_time, end_time, duration, enabled) 
      VALUES (7, "8:30", "21:00", 1440, 1)''');
  }

  // 数据库升级
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // 示例：从版本1升级到2时添加新列
  }
}
