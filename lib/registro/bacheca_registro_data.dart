import 'dart:convert';
import 'dart:io';

import 'package:Messedaglia/main.dart' as main;
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/utils/db_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class BachecaRegistroData extends RegistroData {
  BachecaRegistroData({@required RegistroApi account})
      : super(
            url: 'https://web.spaggiari.eu/rest/v1/students/%uid/noticeboard',
            account: account,
            name: 'bacheca');

  Map<String, bool> bachecaNewFlags = {};

  @override
  Future<Result> parseData(json) async {
    Batch batch = database.batch();

    try {
      List<int> ids = [];
      json = json['items'];
      List<int> deleted_ids = new List();

      json.forEach((c) {
        if (c['cntStatus'] == 'deleted') deleted_ids.add(c['pubId']);
        ids.add(c['evtId']);

        batch.insert(
            'bacheca',
            {
              'id': c['pubId'],
              'usrId': account.usrId,
              'evt': c['evtCode'],
              'start_date':
                  DateTime.parse(c['cntValidFrom']).toLocal().toIso8601String(),
              'end_date':
                  DateTime.parse(c['cntValidTo']).toLocal().toIso8601String(),
              'valid': c['cntValidInRange'] ? 1 : 0,
              'title': c['cntTitle'],
              'attachments': jsonEncode(c['attachments']),
              'new': 1,
              'deleted': (c['cntStatus'] == 'deleted') ? 1 : 0,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore);
      });

      deleted_ids.forEach((id) {
        batch.rawUpdate('UPDATE bacheca SET deleted = 1 WHERE id = ?', [id]);
      });

      batch.delete('bacheca',
          where: 'usrId = ? AND deleted = 1', whereArgs: [account.usrId]);

      batch.delete('bacheca',
          where: 'usrId = ? AND id NOT IN (${ids.join(', ')})',
          whereArgs: [account.usrId]);

      batch.query('bacheca', where: 'usrId = ?', whereArgs: [account.usrId]);

      data = (await batch.commit())
          .last
          .map<Comunicazione>((v) => Comunicazione.parse(v))
          .toList()
            ..sort();

      // data = data.map((e) {
      //   return Comunicazione.parse(e);
      // }).toList()
      //   ..sort();
      await account.update(); // nel caso fosse stata cambiata la classe

      return Result(true, true);
    } catch (e, stack) {
      print(stack);
      return Result(false, false);
    }
  }

  @override
  Future<void> create() async {
    await database.execute(
        'CREATE TABLE IF NOT EXISTS bacheca(id INTEGER PRIMARY KEY, usrId INTEGER, evt TEXT, start_date DATE, end_date DATE, valid BIT, new BIT, deleted BIT, title TEXT, content TEXT, pdf1 BLOB, pdf2 BLOB, attachments TEXT)');
  }

  @override
  Future<void> load() async {
    await super.load();
    data = data.map<Comunicazione>((v) => Comunicazione.parse(v)).toList()
      ..sort();
  }

  int get newComunicazioni =>
      data.length > 0 ? data.where((v) => v.isNew == true).length : 0;

  Future<void> seenAll() async {
    try {
      await database.rawUpdate(
          'UPDATE bacheca SET new = 0 WHERE usrId = ?', [account.usrId]);
      await this.load();
    } catch (e, stack) {
      print(e);
      print(stack);
    }
  }
}

class Comunicazione extends Comparable<Comunicazione> {
  RegistroApi account;
  String evt;
  int id;
  DateTime start_date, end_date;
  bool valid, isNew, deleted;
  String title;
  String content;
  List<dynamic> attachments; //[{},{}]

  Comunicazione(
      {this.evt,
      this.id,
      this.start_date,
      this.end_date,
      this.valid,
      this.title,
      this.attachments,
      this.content,
      this.isNew,
      this.deleted,
      @required this.account});

  Comunicazione.parse(Map raw) {
    attachments = jsonDecode(raw['attachments']);
    content = raw['content'] ?? null;
    end_date = DateTime.parse(raw['end_date']).toLocal();
    evt = raw['evt'];
    id = raw['id'];
    start_date = DateTime.parse(raw['start_date']).toLocal();
    title = raw['title'];
    valid = raw['valid'] == 1 ? true : false;
    isNew = raw['new'] == 1 ? true : false;
    deleted = raw['deleted'] == 1 ? true : false;
  }

  void loadContent(void Function() callback) async {
    try {
      http.Response r = await http.post(
          'https://web.spaggiari.eu/rest/v1/students/${main.session.usrId}/noticeboard/read/$evt/$id/101',
          headers: {
            'Z-Dev-Apikey': 'Tg1NWEwNGIgIC0K',
            'Content-Type': 'application/json',
            'User-Agent': 'CVVS/std/1.7.9 Android/6.0',
            'Z-Auth-Token': main.session.token,
          });
      Map json = jsonDecode(r.body);
      this.content = json['item']['text'];
      int inserted = await database.rawUpdate(
          'UPDATE bacheca SET content = ? WHERE id = ? AND usrId = ?',
          [this.content, this.id, main.session.usrId]);
      await seen();
      this.isNew = false;
      callback();
    } catch (e) {
      callback();
      print(e);
    }
  }

  Future<File> downloadPdf({int number = 1}) async {
    http.Response r;
    var dir = await getTemporaryDirectory();
    File file = File('${dir.path}/${encodePath(title)}.pdf');
    var bytes;
    List<Map> exists = await database
        .rawQuery('SELECT pdf$number FROM bacheca WHERE id=${this.id}');
    exists.first.forEach((key, value) => bytes = value);

    if (bytes != null) {
      await file.writeAsBytes(bytes);
      return file;
    } else {
      try {
        r = await http.get(
          'https://web.spaggiari.eu/rest/v1/students/${main.session.usrId}/noticeboard/attach/$evt/$id/$number',
          headers: {
            'Z-Dev-Apikey': 'Tg1NWEwNGIgIC0K',
            'Content-Type': 'application/json',
            'User-Agent': 'CVVS/std/1.7.9 Android/6.0',
            'Z-Auth-Token': main.session.token,
          },
        );
        await file.writeAsBytes(r.bodyBytes);
        int inserted = await database.rawUpdate(
            'UPDATE bacheca SET pdf$number = ? WHERE id = ? AND usrId = ?',
            [r.bodyBytes, this.id, main.session.usrId]);

        return file;
      } catch (e) {
        print(e);
        return null;
      }
    }
  }

  Future seen() async {
    this.isNew = false;
    int res = await database.rawUpdate(
        'UPDATE bacheca SET new = 0 WHERE id = ? AND usrId = ?',
        [this.id, main.session.usrId]);
  }

  @override
  int compareTo(Comunicazione other) {
    if (start_date.isAtSameMomentAs(other.start_date)) {
      return title.compareTo(other.title); // FIXME on funziona
    }
    return -start_date.compareTo(other.start_date);
  }
}

String encodePath(String name) {
  name = name.replaceAll('"', '');
  name = name.replaceAll('”', '');
  name = name.replaceAll('“', '');
  name = name.replaceAll(' ', '_');
  name = name.replaceAll('/', ' o ');
  name = name.replaceAll('\\', ' ');
  name = name.replaceAll('*', '');
  name = name.replaceAll('?', '');
  name = name.replaceAll('<', '');
  name = name.replaceAll('>', '');
  name = name.replaceAll('|', '');

  return name;
}
