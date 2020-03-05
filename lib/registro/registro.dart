import 'dart:convert';
import 'dart:io';

import 'package:Messedaglia/registro/absences_registro_data.dart';
import 'package:Messedaglia/registro/agenda_registro_data.dart';
import 'package:Messedaglia/registro/bacheca_registro_data.dart';
import 'package:Messedaglia/registro/lessons_registro_data.dart';
import 'package:Messedaglia/registro/note_registro_data.dart';
import 'package:Messedaglia/registro/subjects_registro_data.dart';
import 'package:Messedaglia/registro/voti_registro_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class RegistroApi {
  static String nome, cognome, scuola, uname, pword;
  static DateTime compleanno;
  static int usrId;

  static final VotiRegistroData voti = VotiRegistroData();
  static final AgendaRegistroData agenda = AgendaRegistroData();
  static final SubjectsRegistroData subjects = SubjectsRegistroData();
  static final BachecaRegistroData bacheca = BachecaRegistroData();
  static final NoteRegistroData note = NoteRegistroData();
  static final LessonsRegistroData lessons = LessonsRegistroData();
  static final AbsencesRegistroData absences = AbsencesRegistroData();

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

  static Map<String, String> body = {'ident': null, 'pass': '', 'uid': ''};

  static final String loginUrl = 'https://web.spaggiari.eu/rest/v1/auth/login';

  static String token;
  static DateTime tokenExpiration = null;

  static Future<bool> login(
      {String username,
      String password,
      bool check = true,
      bool force = false}) async {
    username ??= uname;
    password ??= pword;
    if (username == null || password == null) return false;
    if (username == uname &&
        password == pword &&
        !force) if (DateTime.now().isBefore(tokenExpiration) && token != null)
      return true;
    print('logging $username');
    try {
      Map<String, String> headers = {
        'Z-Dev-Apikey': 'Tg1NWEwNGIgIC0K',
        'Content-Type': 'application/json',
        'User-Agent': 'CVVS/std/1.7.9 Android/6.0',
      };

      body['pass'] = password;
      body['uid'] = username;
      http.Response res;

      try {
        res =
            await http.post(loginUrl, headers: headers, body: jsonEncode(body));
      } catch (e) {
        //print(e);
        return false;
      }

      if (res.statusCode != 200) return false;
      Map json = jsonDecode(res.body);
      token = json['token'];
      tokenExpiration = DateTime.parse(json['expire']
              .replaceFirst(':', '', json['expire'].lastIndexOf(':')))
          .toLocal();
      if (!check) return true;
      headers['Z-Auth-Token'] = token;

      res = await http.get(
          "https://web.spaggiari.eu/rest/v1/students/${username.substring(1)}/card",
          headers: headers);

      if (res.statusCode != HttpStatus.ok) {
        token = tokenExpiration = null;
        return false;
      }
      json = jsonDecode(res.body)["card"];

      if (json['schCode'].toString() != 'VRLS0003') {
        token = tokenExpiration = null;
        return false;
      }
      print(json['birthDate']);
      uname = username;
      pword = password;
      scuola = _capitalize("${json["schName"]} ${json["schDedication"]}");
      nome = _capitalize(json["firstName"]);
      cognome = _capitalize(json["lastName"]);
      compleanno = DateTime.parse(json["birthDate"]);
      compleanno =
          DateTime(DateTime.now().year, compleanno.month, compleanno.day);
      if (compleanno.isBefore(DateTime.now()))
        compleanno.add(Duration(days: compleanno.year % 4 == 0 ? 366 : 365));
      usrId = json["usrId"];
      save();
      return true;
    } catch (e, s) {
      print(e);
      print(s);
      token = tokenExpiration = null;
    }
    return false;
  }

  static Future<void> downloadAll(void Function(double) callback) async {
    final List<RegistroData> toDownload = [
      voti,
      agenda,
      subjects,
      bacheca,
      note,
      lessons,
      absences
    ];
    int n = 0;
    toDownload.forEach((data) =>
        data.getData().then((ok) => callback(++n / toDownload.length)));
  }

  static void save() async {
    Map<String, dynamic> data = {
      // il salvataggio delle credenziali e dei token è stato spostato qui dalle SharedPreferences
      'auth': {
        'nome': nome,
        'cognome': cognome,
        'scuola': scuola,
        'compleanno': compleanno.toIso8601String(),
        'usrId': usrId,
        'uname': uname,
        'pword': pword,
        'token': token,
        'tokenExpiration': tokenExpiration.toIso8601String()
      },
      'voti': voti,
      'agenda': agenda,
      'subjects': subjects,
      'bacheca': bacheca,
      // 'note': note, TODO
      'lessons': lessons,
      'absences': absences
      // ecc...
    };
    String json = jsonEncode(data);
    Directory dataDir = await getApplicationSupportDirectory();
    File file = File('${dataDir.path}/data.json');
    if (!file.existsSync()) file.createSync();
    file.writeAsStringSync(json, flush: true);
  }

  static Future<void> load() async {
    Directory dataDir = await getApplicationSupportDirectory();
    File file = File('${dataDir.path}/data.json');
    if (!file.existsSync()) return;
    Map<String, dynamic> data = jsonDecode(file.readAsStringSync());
    voti.fromJson(data['voti']);
    agenda.fromJson(data['agenda']);

    subjects.fromJson(data['subjects']);
    bacheca.fromJson(data['bacheca']);
    // note.fromJson(data['note']); TODO
    lessons.fromJson(data['lessons']);
    absences.fromJson(data['absences']);

    if (data['auth'] == null) return;
    nome = data['auth']['nome'];
    cognome = data['auth']['cognome'];
    scuola = data['auth']['scuola'];
    compleanno = DateTime.parse(data['auth']['compleanno']);
    usrId = data['auth']['usrId'];
    uname = data['auth']['uname'];
    pword = data['auth']['pword'];
    token = data['auth']['token'];
    tokenExpiration = DateTime.parse(data['auth']['tokenExpiration']);
  }
}

abstract class RegistroData {
  DateTime lastUpdate;
  String etag;
  dynamic data = {};
  final String _url;
  bool _loading = false;

  Future<Result> getData() async {
    if (_loading) return Result(true, false);
    _loading = true;
    if (DateTime.now()
        .isAfter(RegistroApi.tokenExpiration)) if (!await RegistroApi.login())
      return Result(false, false);
    Map<String, String> headers = {
      'Z-Dev-Apikey': 'Tg1NWEwNGIgIC0K',
      'Content-Type': 'application/json',
      'User-Agent': 'CVVS/std/1.7.9 Android/6.0',
      'Z-Auth-Token': RegistroApi.token,
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
      if (r.statusCode == HttpStatus.notModified) lastUpdate = DateTime.now();
      return Result(r.statusCode == HttpStatus.notModified, false);
    }
    etag = r.headers['etag'];
    Result result = parseData(json.decode(r.body));
    lastUpdate = DateTime.now();
    _loading = false;
    return result;
  }

  @mustCallSuper
  void fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    lastUpdate = DateTime.parse(json['lastUpdate']);
    etag = json['etag'];
  }

  @mustCallSuper
  Map<String, dynamic> toJson() => {
        'lastUpdate': lastUpdate.toIso8601String(),
        'etag': etag,
      }; // delegates data save to the derivate class

  RegistroData(this._url);

  String get url => _url.replaceFirst('%uid', RegistroApi.usrId.toString());

  Result parseData(dynamic json);
}

class Result {
  final bool ok, reload;
  Result(this.ok, this.reload);
}
