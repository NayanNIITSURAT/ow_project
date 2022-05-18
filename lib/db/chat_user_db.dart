import 'package:owlet/db/db.dart';
import 'package:owlet/db/messages_db.dart';
import 'package:owlet/models/ChatUser.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ChatDB {
  static final ChatDB instance = ChatDB._init();

  ChatDB._init();

  Future<Database> get database async => await DB.initChatDb;

  Future<ChatUser> create(ChatUser chat) async {
    final db = await instance.database;

    // final json = chat.toJson();
    // final columns =
    //     '${ChatFields.title}, ${ChatFields.description}, ${ChatFields.time}';
    // final values =
    //     '${json[ChatFields.title]}, ${json[ChatFields.description]}, ${json[ChatFields.time]}';
    // final id = await db
    //     .rawInsert('INSERT INTO table_name ($columns) VALUES ($values)');
    await db.insert(chatTable, chat.toMap());
    return chat;
  }

  Future<bool> hasChatUser(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      chatTable,
      columns: ['id'],
      where: '${ChatFields.id} = ?',
      whereArgs: [id],
    );

    return maps.isNotEmpty;
  }

  Future<ChatUser> fetchChat(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      chatTable,
      columns: ChatFields.values,
      where: '${ChatFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ChatUser.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<ChatUser>> fetchChats({
    int page = 0,
    int size = 30,
    String? searchParam,
    required int userId,
  }) async {
    final db = await instance.database;

    final result = await db.rawQuery(
        '''
    SELECT user.* FROM $chatTable user
    JOIN (SELECT id, senderId, receiverId FROM messages ORDER BY id DESC) message ON (message.senderId = user.id OR message.receiverId = user.id) WHERE ${searchParam != null && searchParam.isNotEmpty ? "username LIKE '%$searchParam% AND'" : ""} user.id != $userId GROUP BY user.id ORDER BY ${searchParam != null && searchParam.isNotEmpty ? "CASE WHEN username LIKE '$searchParam%' THEN 1 WHEN username LIKE '%$searchParam' THEN 3 ELSE 2 END," : ""} message.id DESC LIMIT ?, ?''',
        [
          page * size,
          size,
        ]);
    List<ChatUser> chats = [];
    for (var map in result) {
      final chat = ChatUser.fromMap(map);

      chats.add(chat.copyWith(
          messages: (await MessageDB.instance.getUserMessages(chat.id))
              .reversed
              .toList()));
    }
    return chats;
  }

  Future<void> deleteDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, chatsDbName);
    await DB.deleteDb(path);
  }

  Future<int> update(ChatUser chat) async {
    final db = await instance.database;

    return db.update(
      chatTable,
      chat.toMap(),
      where: '${ChatFields.id} = ?',
      whereArgs: [chat.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      chatTable,
      where: '${ChatFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
