import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:simple_crud/emp.dart';
import 'package:sqflite/sqflite.dart';

class MyDatabase {
  static final MyDatabase _myDatabase = MyDatabase._privateConstructor();
  // database
  static Database? _database;

  // private constructor
  MyDatabase._privateConstructor();

  factory MyDatabase() => _myDatabase;

  // variables
  final String tableName = 'emp';
  final String columnName = 'name';
  final String columnAddress = 'address';
  final String columnEmail = 'email';
  final String columnContact = 'contact';
  final String columnDate = 'date';

  //
  // init database
  Future<void> initializeDatabase() async {
    // get path to store database
    Directory directory = await getApplicationDocumentsDirectory();
    // path to database
    String path = '${directory.path}/emp.db';
    // create database
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        //
        await db.execute(
          'CREATE TABLE $tableName($columnName TEXT, $columnAddress TEXT, $columnEmail TEXT, $columnContact TEXT, $columnDate TEXT)',
        );
        //
      },
    );
  }

  // CRUD Operations
  // read
  Future<List<Map<String, Object?>>> getEmpList() async {
    //
    //List<Map<String, Object?>> result = await _database.rawQuery('SELECT * FROM $tableName');
    List<Map<String, Object?>> result = await _database!.query(
      tableName,
      orderBy: columnName,
    );
    return result;
    //
  }

  // insert
  Future<int> insertEmp(Employee employee) async {
    //
    int rowsInserted = await _database!.insert(tableName, employee.toMap());
    return rowsInserted;
    //
  }

  // update
  Future<int> updateEmp(Employee employee) async {
    //
    int rowsUpdated = await _database!.update(
      tableName,
      employee.toMap(),
      where: '$columnName = ?',
      whereArgs: [employee.empName],
    );
    return rowsUpdated;
    //
  }

  // delete
  Future<int> deleteEmp(Employee employee) async {
    //
    int rowsDeleted = await _database!.delete(
      tableName,
      where: '$columnName = ?',
      whereArgs: [employee.empName],
    );
    return rowsDeleted;
    //
  }

  // count
  Future<int> countEmp() async {
    //
    /* if (_database == null) {
      print("Database is not initialized");
      return 0;
    } */
    List<Map<String, Object?>> result = await _database!.rawQuery(
      'SELECT COUNT(*) AS count FROM $tableName',
    );
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count;
    //
  }
}
