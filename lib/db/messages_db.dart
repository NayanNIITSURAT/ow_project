import 'package:owlet/db/db.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/models/Message.dart';
import 'package:sqflite/sqflite.dart';

class MessageDB {
  static final MessageDB instance = MessageDB._init();

  Future<Database> get database async => await DB.initChatDb;

  MessageDB._init();

  Future<Message> create(Message message) async {
    final db = await instance.database;

    final id = await db.insert(messageTable, message.toMap());
    return Message.fromMap(message
        .copyWith(
          id: id,
        )
        .toMap());
  }

  Future<Message?> get lastMsg async {
    final db = await instance.database;

    final maps = await db.query(
      messageTable,
      columns: MessageFields.values,
      limit: 1,
      orderBy: 'id DESC',
    );

    if (maps.isNotEmpty) {
      return Message.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> totalUnreadMsgs(int userId) async {
    final db = await instance.database;
    final query =
        '''SELECT COUNT(id) as count FROM ${messageTable} WHERE `${MessageFields.status}` = ? AND senderId != $userId LIMIT 1''';
    final res = await db.rawQuery(query, ['delivered']);
    return res.first['count'] as int;
  }

  Future<int> get lastInsertedId async {
    final db = await instance.database;

    final maps = await db.query(
      messageTable,
      columns: ['id'],
      limit: 1,
      orderBy: 'id DESC',
    );

    if (maps.isNotEmpty) {
      return maps.first['id'] as int;
    } else {
      return -1;
    }
  }

  Future<List<Message>> bulkCreate(List<Message> messages) async {
    final List<Message> _messages = [];

    for (var i = 0; i < messages.length; i++) {
      _messages
          .add(await create(messages[i].copyWith(status: ChatState.DELIVERED)));
    }

    return _messages;
  }

  // Future<List<Message>> bulkCreate(List<Message> messages) async {
  //   final db = await instance.database;
  //   final lastId = await lastInsertedId;
  //   final query = '''INSERT INTO
  //     $messageTable
  //       ($insertFields)
  //     VALUES
  //       ${messages.join(',')};
  //     ''';
  //   final id = await db.rawInsert(query);
  //   print('$lastId $id');
  //   return [];
  // }

  Future<Message?> fetchMessage(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      messageTable,
      columns: MessageFields.values,
      where: '${MessageFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Message.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Message>> getUserMessages(int id,
      {int page = 0, int size = 30}) async {
    final db = await instance.database;

    final orderBy = '${MessageFields.id} DESC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $messageTable ORDER BY $orderBy');

    final result = await db.query(
      messageTable,
      orderBy: orderBy,
      where: '${MessageFields.senderId} = ? OR ${MessageFields.receiverId} = ?',
      whereArgs: [id, id],
      limit: size,
      offset: page * size,
    );
    return result.map((json) => Message.fromMap(json)).toList();
  }

  Future<int> update(Message message) async {
    final db = await instance.database;

    return db.update(
      messageTable,
      message.toMap(),
      where: '${MessageFields.id} = ?',
      whereArgs: [message.id],
    );
  }

  Future<int> updateChatStatus(ChatState status, int senderId) async {
    final db = await instance.database;

    return db.update(
      messageTable,
      {MessageFields.status: chatableType(status)},
      where: '${MessageFields.status} != ? AND ${MessageFields.senderId} = ?',
      whereArgs: [chatableType(status), senderId],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      messageTable,
      where: '${MessageFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
