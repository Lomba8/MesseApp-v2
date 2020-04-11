import 'dart:convert';
import 'dart:io';

import 'package:Messedaglia/main.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/utils/db_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
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
    List<Comunicazione> data2 = <Comunicazione>[];
    Map<String, bool> bachecaNewFlags2 = {};
    Batch batch = database.batch();
    json.forEach((c) {
      if (c['cntStatus'] == 'deleted') return;
      data2.add(Comunicazione(
        c['evtCode'],
        c['pubId'],
        DateTime.parse(c['cntValidFrom']).toLocal(),
        DateTime.parse(c['cntValidTo']).toLocal(),
        c['cntValidInRange'],
        c['cntTitle'],
        c['attachments'],
        account: account,
      ));
      bachecaNewFlags2[c['pubId'].toString()] =
          (bachecaNewFlags[c['pubId'].toString()] ?? !c['readStatus']) ||
              c['cntHasChanged'];

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
            'valid': c['cntValidInRange'].toString(),
            'title': c['cntTitle'],
            'attachments': jsonEncode(c['attachments']),
            'new': 1
          },
          conflictAlgorithm: ConflictAlgorithm.ignore);
    });

    data = data2..sort();
    bachecaNewFlags = bachecaNewFlags2;

    batch.delete('bacheca',
        where:
            'usrId = ? AND end_date > ?', //FIXME: C. 025-20-P Indicazioni per lo svolgimento delle ore di sostituzione non si vede
        whereArgs: [
          account.usrId,
          DateTime(
                  DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .toString()
        ]);
    batch.query('bacheca', where: 'usrId = ?', whereArgs: [account.usrId]);
    var query = (await batch.commit()).last.map((v) => Map.from(v)).toList();
    //debugPrint(query.toString());
    return Result(true, true);
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> tr = super.toJson();
    tr['data'] = data;
    tr['newFlags'] = bachecaNewFlags;
    return tr;
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    data = json['data']
        .map((c) => Comunicazione.fromJson(c, account: account))
        .toList();
    bachecaNewFlags = json['newFlags']
        .map<String, bool>((k, v) => MapEntry<String, bool>(k, v));
  }

  bool hasNewMarks(String id) {
    return bachecaNewFlags[id] ?? false;
  }

  @override
  Future<void> create() async {
    await database.execute(
        'CREATE TABLE IF NOT EXISTS bacheca(id INTEGER PRIMARY KEY, usrId INTEGER, evt TEXT, start_date DATE, end_date DATE, valid INTEGER, new INTEGER, title TEXT, content TEXT, attachments TEXT)');
  }
}

class Comunicazione extends Comparable<Comunicazione> {
  // csotruttore che vada crearea una nuova conmunicazione da un amappa che contirne tutte lecolonne che ono state salvate nel database, quelle di riga 67 deve prednere i valori ed insreirli nella istanza che vado a creare
  final RegistroApi account;
  final String evt;
  final int id;
  final DateTime start_date, end_date;
  final bool valid;
  final String title;
  String content;
  void loadContent(void Function() callback) async {
    http.Response r = await http.post(
        'https://web.spaggiari.eu/rest/v1/students/${account.usrId}/noticeboard/read/$evt/$id/101',
        headers: {
          'Z-Dev-Apikey': 'Tg1NWEwNGIgIC0K',
          'Content-Type': 'application/json',
          'User-Agent': 'CVVS/std/1.7.9 Android/6.0',
          'Z-Auth-Token': account.token,
        });
    Map json = jsonDecode(r.body);
    content = json['item']['text'];
    callback();
  }

  Future<File> downloadPdf() async {
    http.Response r;
    File assetFile;
    File file;
    var dir;

    r = await http.get(
      'https://web.spaggiari.eu/rest/v1/students/${account.usrId}/noticeboard/attach/$evt/$id/1',
      headers: {
        'Z-Dev-Apikey': 'Tg1NWEwNGIgIC0K',
        'Content-Type': 'application/json',
        'User-Agent': 'CVVS/std/1.7.9 Android/6.0',
        'Z-Auth-Token': account.token,
      },
    );
    dir = await getTemporaryDirectory();
    file = File('${dir.path}/${encodePath(title)}.pdf');
    await file.writeAsBytes(r.bodyBytes);
    return file;
  }

  bool get isNew => session.bacheca.bachecaNewFlags[id.toString()] ?? true;
  void seen() => session.bacheca.bachecaNewFlags[id.toString()] = false;

  final List attachments;
  Comunicazione(this.evt, this.id, this.start_date, this.end_date, this.valid,
      this.title, this.attachments,
      {this.content, @required this.account});

  @override
  int compareTo(Comunicazione other) => -start_date.compareTo(other.start_date);

  Map<String, dynamic> toJson() => {
        'evt': evt,
        'id': id,
        'start_date': start_date.toIso8601String(),
        'end_date': end_date.toIso8601String(),
        'valid': valid,
        'title': title,
        'content': content,
        'attachments': attachments
      };

  Comunicazione.fromJson(Map json, {@required this.account})
      : evt = json['evt'],
        id = json['id'],
        start_date = DateTime.parse(json['start_date']),
        end_date = DateTime.parse(json['end_date']),
        valid = json['valid'],
        title = json['title'],
        attachments = json['attachments'],
        content = json['content'];
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
