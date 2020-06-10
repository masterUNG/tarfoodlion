import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tarfoodlion/model/order_sqlite_model.dart';

class SQLiteHelper {
  final String nameDatabase = 'order.db';
  final String tableName = 'orderTABLE';
  final String columnId = 'id';
  final String columnIdShop = 'idShop';
  final String columnNameShop = 'NameShop';
  final String columnNameFood = 'NameFood';
  final String columnPrice = 'Price';
  final String columnAmount = 'Amount';
  final String columnSum = 'Sum';
  int version = 1;

  SQLiteHelper() {
    initDatabase();
  }

  Future<Null> initDatabase() async {
    await openDatabase(join(await getDatabasesPath(), nameDatabase),
        onCreate: (db, version) => db.execute(
            'CREATE TABLE $tableName ($columnId INTEGER PRIMARY KEY, $columnIdShop TEXT, $columnNameShop TEXT, $columnNameFood TEXT, $columnPrice TEXT, $columnAmount TEXT, $columnSum TEXT)'),
        version: version);
  }

  Future<Database> connectedDatabase() async {
    return await openDatabase(join(await getDatabasesPath(), nameDatabase));
  }

  Future<Null> insertValueToSQLite(OrderSQLiteModel orderSQLiteModel) async {
    Database database = await connectedDatabase();
    try {
      database.insert(
        tableName,
        orderSQLiteModel.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {}
  }

  Future<List<OrderSQLiteModel>> readAllSQLite() async {
    Database database = await connectedDatabase();
    List<OrderSQLiteModel> orderSQLiteModels = List();
    List<Map<String, dynamic>> maps = await database.query(tableName);
    for (var map in maps) {
      OrderSQLiteModel orderSQLiteModel = OrderSQLiteModel.fromJson(map);
      orderSQLiteModels.add(orderSQLiteModel);
    }
    return orderSQLiteModels;
  }

  Future<Null> deleteFoodWhereId(int id) async {
    Database database = await connectedDatabase();
    try {
      await database.delete(tableName, where: '$columnId = $id');
    } catch (e) {}
  }

  Future<Null> clearSQLite()async{
    Database database = await connectedDatabase();
    await database.rawDelete('DELETE FROM $tableName');
  }

}
