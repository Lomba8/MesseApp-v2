import 'dart:convert';
import 'dart:io';

import 'package:Messedaglia/registro/registro.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class BachecaRegistroData extends RegistroData {
  BachecaRegistroData()
      : super('https://web.spaggiari.eu/rest/v1/students/%uid/noticeboard');

  Map<String, bool> bachecaNewFlags = {};

  @override
  Result parseData(json) {
    json = json['items'];
    List<Comunicazione> data2 = <Comunicazione>[];
    Map<String, bool> bachecaNewFlags2 = {};
    json.forEach((c) {
      if (c['cntStatus'] == 'deleted') return;
      data2.add(Comunicazione(
          c['evtCode'],
          c['pubId'],
          DateTime.parse(c['cntValidFrom']).toLocal(),
          DateTime.parse(c['cntValidTo']).toLocal(),
          c['cntValidInRange'],
          c['cntTitle'],
          c['attachments']));
      bachecaNewFlags2[c['pubId'].toString()] =
          (bachecaNewFlags[c['pubId'].toString()] ?? !c['readStatus']) ||
              c['cntHasChanged'];
    });

    data = data2..sort();
    bachecaNewFlags = bachecaNewFlags2;
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
    data = json['data'].map((c) => Comunicazione.fromJson(c)).toList();
    bachecaNewFlags = json['newFlags']
        .map<String, bool>((k, v) => MapEntry<String, bool>(k, v));
  }

  bool hasNewMarks(String id) {
    return bachecaNewFlags[id] ?? false;
  }
}

class Comunicazione extends Comparable<Comunicazione> {
  final String evt;
  final int id;
  final DateTime start_date, end_date;
  final bool valid;
  final String title;
  String content;
  void loadContent(void Function() callback) async {
    http.Response r = await http.post(
        'https://web.spaggiari.eu/rest/v1/students/${RegistroApi.usrId}/noticeboard/read/$evt/$id/101',
        headers: {
          'Z-Dev-Apikey': 'Tg1NWEwNGIgIC0K',
          'Content-Type': 'application/json',
          'User-Agent': 'CVVS/std/1.7.9 Android/6.0',
          'Z-Auth-Token': RegistroApi.token,
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
      'https://web.spaggiari.eu/rest/v1/students/${RegistroApi.usrId}/noticeboard/attach/$evt/$id/1',
      headers: {
        'Z-Dev-Apikey': 'Tg1NWEwNGIgIC0K',
        'Content-Type': 'application/json',
        'User-Agent': 'CVVS/std/1.7.9 Android/6.0',
        'Z-Auth-Token': RegistroApi.token,
      },
    );
    dir = await getTemporaryDirectory();
    file = File('${dir.path}/${encodePath(title)}.pdf');
    await file.writeAsBytes(r.bodyBytes);
    return file;
  }

  bool get isNew => RegistroApi.bacheca.bachecaNewFlags[id.toString()] ?? true;
  void seen() => RegistroApi.bacheca.bachecaNewFlags[id.toString()] = false;

  final List attachments;
  Comunicazione(this.evt, this.id, this.start_date, this.end_date, this.valid,
      this.title, this.attachments,
      [this.content]);

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

  static Comunicazione fromJson(Map json) => Comunicazione(
      json['evt'],
      json['id'],
      DateTime.parse(json['start_date']),
      DateTime.parse(json['end_date']),
      json['valid'],
      json['title'],
      json['attachments'],
      json['content']);
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
