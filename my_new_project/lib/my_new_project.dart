import 'dart:io';
import 'package:mysql1/mysql1.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static MySqlConnection _database;

  Future<MySqlConnection> get database async {
    if (_database != null) return _database;
    _database = await DBconnection();
    return _database;
  }

  Future<void> storeUserCredentials(UserCredentials userCredentials) async {
    final db = await database;
    await db.execute('''
      INSERT INTO user_credentials (username, account_number, location)
      VALUES (?, ?, ?)
    ''', [userCredentials.username, userCredentials.accountNumber, userCredentials.location]);

    // Redirect user to car type selection after successful registration
    print('Registration successful! Please choose a car type:');
    await chooseCarType();
  }

  Future<void> chooseCarType() async {
    List<String> carTypes = ['Sedan', 'SUV', 'Truck', 'Electric', 'Hybrid'];
    String selectedCarType;

    print('Select the type of car you want to purchase:');
    for (int i = 0; i < carTypes.length; i++) {
      print('${i + 1}. ${carTypes[i]}');
    }

    while (true) {
      String input = stdin.readLineSync() ?? '';
      int choice = int.tryParse(input);

      if (choice != null && choice > 0 && choice <= carTypes.length) {
        selectedCarType = carTypes[choice - 1];
        break;
      } else {
        print('Invalid choice. Please try again.');
      }
    }

    print('You have chosen: $selectedCarType');

    // Save car type selection to database or perform other actions
    // ...
  }

  Future<UserCredentials> getUserCredentials(String username) async {
    final db = await database;
    var results = await db.query('SELECT * FROM user_credentials WHERE username = ?', [username]);
    if (results.isNotEmpty) {
      return UserCredentials(
        username: results.first['username'],
        accountNumber: results.first['account_number'],
        location: results.first['location'],
      );
    } else {
      return null;
    }
  }
}

class UserCredentials {
  final String username;
  final String accountNumber;
  final String location;

  UserCredentials({this.username, this.accountNumber, this.location});

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'account_number': accountNumber,
      'location': location,
    };
  }

  factory UserCredentials.fromMap(Map<String, dynamic> map) {
    return UserCredentials(
      username: map['username'],
      accountNumber: map['account_number'],
      location: map['location'],
    );
  }
}

Future<MySqlConnection> DBconnection() async {
  var con = await ConnectionSettings(
    host: '127.0.0.1',
    port: 3306,
    user: 'root',
    password: '12345',
    db: 'dartandmysql',
  );

  var conn = await MySqlConnection.connect(con);

  return conn;
}