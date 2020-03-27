import 'package:Messedaglia/registro/registro.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database database;

Future<void> init() async {
  database = await openDatabase(
    join(await getDatabasesPath(), 'database.db'),
    onCreate: (db, version) {
      db.execute(
          'CREATE TABLE auth(usrId INTEGER PRIMARY KEY, nome TEXT, cognome TEXT, scuola TEXT, uname TEXT, pword TEXT, token TEXT, cls CHARACTER(3), birth DATE, tokenExpiration DATETIME)');
      db.execute(
          'CREATE TABLE sections(name TEXT PRIMARY KEY, usrId INTEGER, etag TEXT, lastUpdate DATETIME)');
    },
    onUpgrade: (db, oldVersion, newVersion) {
      switch (oldVersion) {
        case 1:
          db.delete('auth');
          continue c2;
        c2: case 2: case 3:
          db.execute(
              'CREATE TABLE sections(name TEXT PRIMARY KEY, usrId INTEGER, etag TEXT, lastUpdate DATETIME)'); continue c4;
        c4: case 4: case 5: db.delete('auth'); continue c6;
        c6: case 6: case 7: {
          db.delete('auth');
          db.delete('sections');
        }
      }
    },
    version: 8,
  );
  accounts = (await database.query('auth'))
      .map((raw) => RegistroApi.parse(raw))
      .toList();
}

List<RegistroApi> accounts;
