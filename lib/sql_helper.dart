import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SqlHelper {
  // Create items table query
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        description TEXT,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  // Create DB
  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'notes.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new item
  static Future<int> createItem(String title, String? description) async {
    final db = await SqlHelper.db();

    final data = {'title': title, 'description': description};
    final query = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return query;
  }

  // Read all items
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SqlHelper.db();

    final query = await db.query('items', orderBy: 'id');

    return query;
  }

  // Read single item
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SqlHelper.db();

    final query =
        await db.query('items', where: 'id = ?', whereArgs: [id], limit: 1);

    return query;
  }

  // Update an item
  static Future<int> updateItem(
      int id, String title, String? description) async {
    final db = await SqlHelper.db();

    final data = {
      'title': title,
      'description': description,
      'updated_at': DateTime.now().toString()
    };
    final query =
        await db.update('items', data, where: 'id = ?', whereArgs: [id]);

    return query;
  }

  // Delete an item
  static Future<void> deleteItem(int id) async {
    final db = await SqlHelper.db();

    try {
      await db.delete('items', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint("Something went wrong! Error: $e");
    }
  }
}
