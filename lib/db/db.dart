import 'package:owlet/models/ChatUser.dart';
import 'package:owlet/models/Message.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DB {
  static Database? _database;

  static Future<Database> _initDB(
      String dbName, Function(Database, int)? onCreate) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(path, version: 1, onCreate: onCreate);
  }

  static Future<void> deleteDb(String path) async {
    try {
      (await openDatabase(path)).close();
      await deleteDatabase(path);
    } catch (e) {
      print(e);
    }
  }

// final int11 = 'int(11)';
// final notNull = 'NOT NULL';
// final idType = '$int11 $notNull PRIMARY KEY';
// final boolType = 'BOOLEAN DEFAULT FALSE';
// final String createChatTableQuery = '''CREATE TABLE $chatTable (
//         `${ChatFields.id}` $idType,
//         `${ChatFields.username}` TEXT $notNull,
//         `${ChatFields.avartar}` TEXT $notNull,
//         `${ChatFields.confirmed}` $boolType,
//         `${ChatFields.iFollow}` $boolType,
//         `${ChatFields.isOnline}` $boolType,
//         `${ChatFields.lastSeen}` TEXT $notNull,
//         `${ChatFields.hasVerifiedCompany}` $boolType
//       );''';

  static Future _createChatTables(Database db, int version) async {
    await db.execute(createChatTableQuery);
    await db.execute(createMessageTableQuery);
  }

  static Future<Database> get initChatDb async {
    if (_database != null) return _database!;

    _database = await _initDB(chatsDbName, _createChatTables);
    return _database!;
  }
}
