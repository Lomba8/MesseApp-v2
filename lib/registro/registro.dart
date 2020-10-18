import 'dart:convert';
import 'dart:io';

import 'package:Messedaglia/main.dart';
import 'package:Messedaglia/registro/absences_registro_data.dart';
import 'package:Messedaglia/registro/agenda_registro_data.dart';
import 'package:Messedaglia/registro/bacheca_registro_data.dart';
import 'package:Messedaglia/registro/didattica_registro_data.dart';
import 'package:Messedaglia/registro/lessons_registro_data.dart';
import 'package:Messedaglia/registro/note_registro_data.dart';
import 'package:Messedaglia/registro/subjects_registro_data.dart';
import 'package:Messedaglia/registro/voti_registro_data.dart';
import 'package:Messedaglia/utils/db_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqlite_api.dart';

final String loginUrl = 'https://web.spaggiari.eu/rest/v1/auth/login';

class RegistroApi {
  final String uname, pword;
  int usrId;
  String nome, cognome, scuola, token, cls;
  DateTime tokenExpiration, birth;

  RegistroApi({@required this.uname, @required this.pword}) {
    init();
  }
  RegistroApi.parse(Map map)
      : this.uname = map['uname'],
        this.pword = map['pword'],
        this.usrId = map['usrId'],
        this.nome = map['nome'],
        this.cognome = map['cognome'],
        this.scuola = map['scuola'],
        this.token = map['token'],
        this.cls = map['cls'],
        this.tokenExpiration = DateTime.tryParse(map['tokenExpiration']),
        this.birth = DateTime.tryParse(map['birth']) {
    init();
  }

  void init() {
    voti = VotiRegistroData(account: this);
    agenda = AgendaRegistroData(account: this);
    subjects = SubjectsRegistroData(account: this);
    bacheca = BachecaRegistroData(account: this);
    note = NoteRegistroData(account: this);
    lessons = LessonsRegistroData(account: this);
    absences = AbsencesRegistroData(account: this);
    didactics = DidatticaRegistroData(account: this);
  }

  Map get asMap => <String, dynamic>{
        'usrId': usrId,
        'nome': nome,
        'cognome': cognome,
        'scuola': scuola,
        'uname': uname,
        'pword': pword,
        'token': token,
        'cls': cls,
        'birth': birth.toIso8601String(),
        'tokenExpiration': tokenExpiration.toIso8601String(),
      };

  Future<void> register() async {
    await database.insert('auth', asMap,
        conflictAlgorithm: ConflictAlgorithm.replace);
    await voti.register();
    await agenda.register();
    await subjects.register();
    await bacheca.register();
    await note.register();
    await lessons.register();
    await absences.register();
    await didactics.register();
  }

  Future<void> update() async => await database.update(
      'auth',
      <String, dynamic>{
        'cls': cls,
        'token': token,
        'tokenExpiration': tokenExpiration.toIso8601String()
      },
      where: 'usrId = ?',
      whereArgs: [usrId]);

  VotiRegistroData voti;
  AgendaRegistroData agenda;
  SubjectsRegistroData subjects;
  BachecaRegistroData bacheca;
  NoteRegistroData note;
  LessonsRegistroData lessons;
  AbsencesRegistroData absences;
  DidatticaRegistroData didactics;

  static String _capitalize(String s) {
    List<String> parole = [];
    parole = s.split(' ');
    String capitalizzato = ' ';
    parole.forEach((parola) {
      capitalizzato +=
          parola[0].toUpperCase() + parola.substring(1).toLowerCase() + ' ';
    });
    return capitalizzato.trim();
  }

  Future<String> login({bool check = true, bool force = false}) async {
    if (uname == null || pword == null)
      return 'Username e/o password non validi';
    if (uname == uname && pword == pword && !force) if (token != null &&
        DateTime.now().isBefore(tokenExpiration)) return '';
    try {
      Map<String, String> headers = {
        'Z-Dev-Apikey': 'Tg1NWEwNGIgIC0K',
        'Content-Type': 'application/json',
        'User-Agent': 'CVVS/std/1.7.9 Android/6.0',
      };
      http.Response res;

      try {
        res = await http.post(loginUrl,
            headers: headers,
            body: jsonEncode({'ident': null, 'pass': pword, 'uid': uname}));
      } catch (e) {
        print(e);
        return res.reasonPhrase;
      }

      if (res.statusCode != 200) return res.reasonPhrase;
      Map json = jsonDecode(res.body);
      token = json['token'];
      tokenExpiration = DateTime.parse(json['expire']
              .replaceFirst(':', '', json['expire'].lastIndexOf(':')))
          .toLocal();
      if (!check) {
        update();
        return '';
      }
      headers['Z-Auth-Token'] = token;

      res = await http.get(
          "https://web.spaggiari.eu/rest/v1/students/${uname.substring(1)}/card",
          headers: headers);
      if (res.statusCode != HttpStatus.ok) {
        token = tokenExpiration = null;
        return res.reasonPhrase;
      }
      json = jsonDecode(res.body)["card"];

      if (json['schCode'].toString() != 'VRLS0003') {
        token = tokenExpiration = null;
        return 'Haha ci hai provato';
      }
      scuola = _capitalize("${json["schName"]} ${json["schDedication"]}");
      nome = _capitalize(json["firstName"]);
      cognome = _capitalize(json["lastName"]);
      birth = DateTime.parse(json["birthDate"]);
      /*compleanno =
          DateTime(DateTime.now().year, compleanno.month, compleanno.day);
      if (compleanno.isBefore(DateTime.now()))
        compleanno.add(Duration(days: compleanno.year % 4 == 0 ? 366 : 365));*/
      usrId = json["usrId"];
      accounts.add(this);
      await register();
      return '';
    } catch (e, s) {
      print(e);
      print(s);
    }
    return 'Errore durante il login';
  }

  Future<void> downloadAll(void Function(double) callback,
      {List<Future Function()> downloaders = const []}) async {
    final Map<String, RegistroData> toDownload = {
      'voti': voti,
      'agenda': agenda,
      'subjects': subjects,
      'bacheca': bacheca,
      'note': note,
      'lessons': lessons,
      'absences': absences,
      'didactics': didactics
    };
    int n = 0;
    toDownload.forEach((name, data) async {
      await data.getData();
      callback(++n / (toDownload.length + downloaders.length));
    });
    downloaders.forEach((downloader) async {
      await downloader();
      callback(++n / (toDownload.length + downloaders.length));
    });
  }

  void save() async {
    saveData(subjects, 'subjects'); //FIXME toglierlo?
    saveData(bacheca, 'bacheca'); // togliere quando si implemmenta il register
    saveData(lessons, 'lessons'); // fatto
    saveData(absences, 'absences');
    saveData(didactics, 'didactics');
  }

  Future<void> load() async {
    // se sei offline ricaarica da locale
    await voti.load();
    await agenda.load();
    await bacheca.load();
    await absences.load();
    await note.load();
    dynamic data = await loadData('subjects');
    if (data != null) subjects.fromJson(data);
    data = await loadData('lessons');
    if (data != null) lessons.fromJson(data);
    data = await loadData('didacticd');
    if (data != null) didactics.fromJson(data);
  }
}

abstract class RegistroData {
  final RegistroApi account;
  final String name;

  DateTime lastUpdate;
  String etag;
  dynamic data = {}; //= <String, dynamic>{};
  final String _url;
  bool _loading = false;

  RegistroData(
      {@required this.account, @required String url, @required this.name})
      : _url = url;

  Map<String, dynamic> asMap(String name) => <String, dynamic>{
        'name': name,
        'usrId': account.usrId,
        'etag': etag,
        'lastUpdate': lastUpdate?.toIso8601String()
      };

  Future<void> create();

  Future<void> register() async {
    await database.insert('sections', asMap(name),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await create();
  }

  Future<void> update(String name) async => await database.update(
      'sections', {'etag': etag, 'lastUpdate': lastUpdate?.toIso8601String()},
      where: 'name = ? AND usrId = ?', whereArgs: [name, account.usrId]);

  Future<void> load() async {
    List section = (await database.query('sections',
        columns: ['etag', 'lastUpdate'],
        where: 'name = ? AND usrId = ?',
        whereArgs: [name, account.usrId]));
    if (section.isNotEmpty) {
      etag = section.first['etag'];
      lastUpdate = DateTime.tryParse(section.first['lastUpdate']);
    }
    data = (await database
            .query(name, where: 'usrId = ?', whereArgs: [account.usrId]))
        .map((v) => Map.from(v))
        .toList();
  }

  Future<Result> getData() async {
    if (_loading) return Result(true, false);
    _loading = true;
    if (DateTime.now()
        .isAfter(account.tokenExpiration)) if (await account.login() != '')
      return Result(false, false);
    Map<String, String> headers = {
      'Z-Dev-Apikey': 'Tg1NWEwNGIgIC0K',
      'Content-Type': 'application/json',
      'User-Agent': 'CVVS/std/1.7.9 Android/6.0',
      'Z-Auth-Token': account.token,
      'Z-If-None-Match': etag
    };
    http.Response r;

    try {
      r = await http.get(url, headers: headers);
    } catch (e) {
      //print(e);
      return null;
    }

    if (r.statusCode != HttpStatus.ok) {
      _loading = false;
      if (r.statusCode == HttpStatus.notModified) {
        lastUpdate = DateTime.now();
        update(name);
      }
      return Result(r.statusCode == HttpStatus.notModified, false);
    }
    etag = r.headers['etag'];
    Result result = await parseData(json.decode(r.body));
    lastUpdate = DateTime.now();
    _loading = false;
    update(name);
    return result;
  }

  @mustCallSuper
  void fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    lastUpdate =
        json['lastUpdate'] == null ? null : DateTime.parse(json['lastUpdate']);
    etag = json['etag'];
  }

  @mustCallSuper
  Map<String, dynamic> toJson() => {
        'lastUpdate': lastUpdate?.toIso8601String(),
        'etag': etag,
      }; // delegates data save to the derivate class

  String get url => _url.replaceFirst('%uid', account.usrId.toString());

  Future<Result> parseData(dynamic json);
}

class Result {
  final bool ok, reload;
  Result(this.ok, this.reload);
}
