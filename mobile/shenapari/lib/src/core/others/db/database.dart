// import 'dart:developer';
//
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
//
// import 'db_config.dart';
//
// class AppDatabase {
//   static Database? _database;
//   static final AppDatabase instance = AppDatabase._();
//
//   AppDatabase._();
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }
//
//   Future<Database> _initDatabase() async {
//     final path = await _getDatabasePath();
//     return await openDatabase(
//       path,
//       version: DatabaseConfig.version,
//       onCreate: _createDatabase,
//       onOpen: (db) async {
//         await checkTable(db);
//       },
//     );
//   }
//
//   Future<void> clear() async {
//     final path = await _getDatabasePath();
//     await deleteDatabase(path);
//     _database = null;
//   }
//
//   Future<void> checkTable(Database db) async {
//     final result = await db.rawQuery('''
//     SELECT name
//     FROM sqlite_master
//     WHERE type='table'
//   ''');
//
//     log('📦 Tables: $result');
//   }
//
//   Future<String> _getDatabasePath() async {
//     final documentsDirectory = await getApplicationDocumentsDirectory();
//     return join(documentsDirectory.path, DatabaseConfig.name);
//   }
//
//   Future<void> _createDatabase(Database db, int version) async {
//     final movieFields = DatabaseConfig.movie.fields;
//     await db.execute('''
//       CREATE TABLE ${DatabaseConfig.movie.name}(
//       ${movieFields.id} TEXT PRIMARY KEY,
//       ${movieFields.title} TEXT,
//       ${movieFields.type} TEXT,
//       ${movieFields.image} TEXT,
//       ${movieFields.startYear} INTEGER,
//       ${movieFields.endYear} INTEGER,
//       ${movieFields.movieDurationInSec} INTEGER,
//       ${movieFields.genres} TEXT,
//       ${movieFields.rating} TEXT,
//       ${movieFields.description} TEXT,
//       ${movieFields.section} TEXT,
//       ${movieFields.cachedAt} INTEGER
//       )
//       ''');
//   }
//
// //
// //   ///
// //   /// Notification
// //   ///
// //
// //   Future<void> insertNotification(NotificationData data) async {
// //     final db = await instance.database;
// //     final dataM = NotificationDbMapper().mapperTo(data);
// //     await db.insert(
// //       AppDatabase.notificationTable.name,
// //       dataM,
// //       conflictAlgorithm: ConflictAlgorithm.replace,
// //     );
// //   }
// //
// //   Future<NotificationData?> getNotification(String id) async {
// //     final db = await instance.database;
// //     final result = await db.query(
// //       AppDatabase.notificationTable.name,
// //       where: "id = ?",
// //       whereArgs: [id],
// //     );
// //     if (result.isNotEmpty) {
// //       return NotificationDbMapper().mapperFrom(result.first);
// //     }
// //     return null;
// //   }
// //
// //   Future<List<NotificationData>?> getAllNotification({String? type}) async {
// //     final db = await instance.database;
// //     String whereString = "";
// //     List<Object> whereArgs = [];
// //
// //     if (type != null) {
// //       whereString += "type = ?";
// //       whereArgs.add(type);
// //     }
// //
// //     List<Map<String, dynamic>> maps = await db.query(
// //       AppDatabase.notificationTable.name,
// //       where: whereString.isNotEmpty ? whereString : null,
// //       whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
// //     );
// //     if (maps.isNotEmpty) {
// //       return maps.map((e) => NotificationDbMapper().mapperFrom(e)).toList();
// //     }
// //     return null;
// //   }
// //
// //   Future<void> deleteNotification(String id) async {
// //     final db = await instance.database;
// //     final notificationFields = AppDatabase.notificationTable.fields;
// //     final result = await db.delete(
// //       AppDatabase.notificationTable.name,
// //       where: "${notificationFields.id} = ? ",
// //       whereArgs: [id],
// //     );
// //   }
// //
// //   Future<void> deleteAllNotifications() async {
// //     final db = await instance.database;
// //     await db.delete(AppDatabase.notificationTable.name);
// //   }
// }
