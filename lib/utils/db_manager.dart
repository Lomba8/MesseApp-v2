import 'package:Messedaglia/registro/registro.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database database;

final List<String> days = ['lun', 'mar', 'mer', 'gio', 'ven', 'sab'];

Future<void> init() async {
  database = await openDatabase(
    join(await getDatabasesPath(), 'database.db'),
    onCreate: (db, version) {
      db.execute(
          'CREATE TABLE auth(usrId INTEGER PRIMARY KEY, nome TEXT, cognome TEXT, scuola TEXT, uname TEXT, pword TEXT, token TEXT, cls CHARACTER(3), birth DATE, tokenExpiration DATETIME)');
      db.execute(
          'CREATE TABLE sections(name TEXT PRIMARY KEY, usrId INTEGER, etag TEXT, lastUpdate DATETIME)');
      db.execute('CREATE TABLE orari(cls TEXT PRIMARY KEY, ' +
          (() sync* {
            for (String day in days)
              for (int hour = 0; hour < 6; hour++) yield '$day$hour TEXT';
          }()
              .join(', ')) +
          ', url TEXT)');
    },
    onUpgrade: (db, oldVersion, newVersion) {
      switch (oldVersion) {
        case 1:
          db.delete('auth');
          continue c2;
        c2:
        case 2:
        case 3:
          db.execute(
              'CREATE TABLE sections(name TEXT PRIMARY KEY, usrId INTEGER, etag TEXT, lastUpdate DATETIME)');
          continue c4;
        c4:
        case 4:
        case 5:
          db.delete('auth');
          continue c6;
        c6:
        case 6:
        case 7:
          {
            db.delete('auth');
            db.delete('sections');
            continue c8;
          }
        c8:
        case 8: case 9: case 10:
          db.execute('CREATE TABLE orari(cls TEXT PRIMARY KEY, ' +
              (() sync* {
                for (String day in days)
                  for (int hour = 0; hour < 6; hour++) yield '$day$hour TEXT';
              }()
                  .join(', ')) +
              ', url TEXT)'); continue c11;
        c11: case 11: case 12: db.delete('agenda'); continue c13;
        c13: case 13: {
          db.delete('auth');
          db.delete('sections');
          db.execute('DROP TABLE agenda');
        }
      }
    },
    version: 14,
  );
  accounts = (await database.query('auth'))
      .map((raw) => RegistroApi.parse(raw))
      .toList();
}

List<RegistroApi> accounts;
