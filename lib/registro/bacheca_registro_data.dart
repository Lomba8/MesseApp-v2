import 'dart:convert';
import 'dart:io';

import 'package:Messedaglia/main.dart';
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
    json = json['items'];
    List<int> deleted_ids = new List();
    Batch batch = database.batch();
    json.forEach((c) {
      if (c['cntStatus'] == 'deleted') deleted_ids.add(c['pubId']);

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
            'attachments':
                jsonEncode(c['attachments'].isEmpty ? {} : c['attachments'][0]),
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

    batch.query('bacheca', where: 'usrId = ?', whereArgs: [account.usrId]);

    data = (await batch.commit()).last.map((v) => Map.from(v)).toList();

    data = data.map((e) {
      return Comunicazione(
        account: account,
        attachments: jsonDecode(e['attachments']),
        content: e['content'] ?? null,
        end_date: DateTime.parse(e['end_date']).toLocal(),
        evt: e['evt'],
        id: e['id'],
        start_date: DateTime.parse(e['start_date']).toLocal(),
        title: e['title'],
        valid: e['valid'] == 1 ? true : false,
        isNew: e['new'] == 1 ? true : false,
        deleted: e['deleted'] == 1 ? true : false,
      );
    }).toList()
      ..sort();
    return Result(true, true);
  }

  @override
  Future<void> create() async {
    await database.execute(
        'CREATE TABLE IF NOT EXISTS bacheca(id INTEGER PRIMARY KEY, usrId INTEGER, evt TEXT, start_date DATE, end_date DATE, valid BIT, new BIT, deleted BIT, title TEXT, content TEXT, pdf BLOB, attachments TEXT)');
  }

  @override
  Future<void> load() async {
    await super.load();
    data = data.map((e) {
      return Comunicazione(
        account: account,
        attachments: jsonDecode(e['attachments']),
        content: e['content'] ?? null,
        end_date: DateTime.parse(e['end_date']).toLocal(),
        evt: e['evt'],
        id: e['id'],
        start_date: DateTime.parse(e['start_date']).toLocal(),
        title: e['title'],
        valid: e['valid'] == 1 ? true : false,
        isNew: e['new'] == 1 ? true : false,
        deleted: e['deleted'] == 1 ? true : false,
      );
    }).toList()
      ..sort();
  }

  int get newComunicazioni => data.where((v) => v.isNew == true).length;
}

class Comunicazione extends Comparable<Comunicazione> {
  final RegistroApi account;
  final String evt;
  final int id;
  final DateTime start_date, end_date;
  bool valid, isNew, deleted;
  final String title;
  String content;
  final Map attachments;

  void loadContent(void Function() callback) async {
    try {
      http.Response r = await http.post(
          'https://web.spaggiari.eu/rest/v1/students/${account.usrId}/noticeboard/read/$evt/$id/101',
          headers: {
            'Z-Dev-Apikey': 'Tg1NWEwNGIgIC0K',
            'Content-Type': 'application/json',
            'User-Agent': 'CVVS/std/1.7.9 Android/6.0',
            'Z-Auth-Token': account.token,
          });
      Map json = jsonDecode(r.body);
      this.content = json['item']['text'];
      int inserted = await database.rawUpdate(
          'UPDATE bacheca SET content = ? WHERE id = ?',
          [this.content, this.id]);
      await seen();
      callback();
    } catch (e) {
      callback();
      print(e);
    }
  }

  Future<File> downloadPdf() async {
    http.Response r;
    var dir = await getTemporaryDirectory();
    File file = File('${dir.path}/${encodePath(title)}.pdf');
    var bytes;
    List<Map> exists =
        await database.rawQuery('SELECT pdf FROM bacheca WHERE id=${this.id}');
    exists.first.forEach((key, value) => bytes = value);

    if (bytes != null) {
      await file.writeAsBytes(bytes);
      return file;
    } else {
      try {
        r = await http.get(
          'https://web.spaggiari.eu/rest/v1/students/${account.usrId}/noticeboard/attach/$evt/$id/1',
          headers: {
            'Z-Dev-Apikey': 'Tg1NWEwNGIgIC0K',
            'Content-Type': 'application/json',
            'User-Agent': 'CVVS/std/1.7.9 Android/6.0',
            'Z-Auth-Token': account.token,
          },
        );
        await file.writeAsBytes(r.bodyBytes);
        int inserted = await database.rawUpdate(
            'UPDATE bacheca SET pdf = ? WHERE id = ?', [r.bodyBytes, this.id]);

        return file;
      } catch (e) {
        print(e);
        return null;
      }
    }
  }

  //bool get isNew => session.bacheca.bachecaNewFlags[id.toString()] ?? true; TODO
  //void seen() => session.bacheca.bachecaNewFlags[id.toString()] = false;    TODO
  Future<void> seen() async {
    this.isNew = false;
    int res = await database
        .rawUpdate('UPDATE bacheca SET new = 0 WHERE id = ?', [this.id]);
  }

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
