import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';
import '../models/product.dart';

class ProductService {
  final dbHelper = DatabaseHelper.instance;

  Future<void> insertProduct(Product product) async {
    final db = await dbHelper.database;
    await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Product>> getAllProducts() async {
    final db = await dbHelper.database;
    final result = await db.query('products');
    return result.map((e) => Product.fromMap(e)).toList();
  }

  Future<void> clearProducts() async {
    final db = await dbHelper.database;
    await db.delete('products');
  }

  Future<void> seedIfEmpty(List<Product> products) async {
    final db = await dbHelper.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM products'),
    );

    if (count == 0) {
      final batch = db.batch();
      for (final p in products) {
        batch.insert(
          'products',
          p.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    }
  }
}