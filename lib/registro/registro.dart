import 'dart:convert';
import 'dart:io';

import 'package:Messedaglia/main.dart';
import 'package:Messedaglia/registro/absences_registro_data.dart';
import 'package:Messedaglia/registro/agenda_registro_data.dart';
import 'package:Messedaglia/registro/bacheca_registro_data.dart';
import 'package:Messedaglia/registro/lessons_registro_data.dart';
import 'package:Messedaglia/registro/note_registro_data.dart';
import 'package:Messedaglia/registro/subjects_registro_data.dart';
import 'package:Messedaglia/registro/voti_registro_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegistroApi {
  static String nome, cognome, scuola, uname, pword, cls;
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
      if (!check) {
        _saveAuth();
        return true;
      }
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
      _saveAuth();
      return true;
    } catch (e, s) {
      print(e);
      print(s);
      token = tokenExpiration = null;
    }
    return false;
  }

  static Future<void> downloadAll(void Function(double) callback) async {
    final Map<String, RegistroData> toDownload = {
      'voti': voti,
      'agenda': agenda,
      'subjects': subjects,
      'bacheca': bacheca,
      'note': note,
      'lessons': lessons,
      'absences': absences
    };
    int n = 0;
    toDownload.forEach((name, data) async {
      dynamic json = await loadData(name);
      if (json != null) data.fromJson(json);
      await data.getData();
      callback(++n / toDownload.length);
    });
  }

  static void _saveAuth () => saveData({
        'nome': nome,
        'cognome': cognome,
        'scuola': scuola,
        'compleanno': compleanno.toIso8601String(),
        'usrId': usrId,
        'uname': uname,
        'pword': pword,
        'token': token,
        'tokenExpiration': tokenExpiration.toIso8601String(),
        'cls': cls
      }, 'auth');
  static Future loadAuth () async {
    Map data = await loadData('auth');
    if (data == null) return;
    nome = data['nome'];
    cognome = data['cognome'];
    scuola = data['scuola'];
    compleanno = DateTime.parse(data['compleanno']);
    usrId = data['usrId'];
    uname = data['uname'];
    pword = data['pword'];
    token = data['token'];
    tokenExpiration = DateTime.parse(data['tokenExpiration']);
    cls = data['cls'];
  }
  

  static void save() async {
    _saveAuth();
    saveData(voti, 'voti');
    saveData(agenda, 'agenda');
    saveData(subjects, 'subjects');
    saveData(bacheca, 'bacheca');
    saveData(lessons, 'lessons');
    saveData(absences, 'absences');
  }
 
  static Future<void> load() async {
    await loadAuth();
    dynamic data = await loadData('voti');
    if (data != null) voti.fromJson(data);
    data = await loadData('agenda');
    if (data != null) agenda.fromJson(data);
    data = await loadData('subjects');
    if (data != null) subjects.fromJson(data);
    data = await loadData('bacheca');
    if (data != null) bacheca.fromJson(data);
    data = await loadData('lessons');
    if (data != null) lessons.fromJson(data);
    data = await loadData('absences');
    if (data != null) absences.fromJson(data);
  }
}

abstract class RegistroData {
  DateTime lastUpdate;
  String etag;
  dynamic data = <String, dynamic>{};
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
    lastUpdate = json['lastUpdate'] == null ? null : DateTime.parse(json['lastUpdate']);
    etag = json['etag'];
  }

  @mustCallSuper
  Map<String, dynamic> toJson() => {
        'lastUpdate': lastUpdate?.toIso8601String(),
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
