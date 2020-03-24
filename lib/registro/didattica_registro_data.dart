import 'dart:convert';
import 'dart:math';

import 'package:Messedaglia/registro/registro.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DidatticaRegistroData extends RegistroData {
  DidatticaRegistroData()
      : super('https://web.spaggiari.eu/rest/v1/students/%uid/didactics');

  Map<String, bool> bachecaNewFlags = {};

  @override
  Result parseData(json) {
    json = json['didacticts'];
    data = <CustomPath>[];

    json.forEach((teacher) {
      data.add(CustomDirectory(
        name: teacher['teacherName'],
        children: teacher['folders']
            .map<CustomDirectory>((folder) => CustomDirectory(
                name: folder['folderName'],
                children: folder['contents']
                    .map<CustomFile>((content) => CustomFile(
                        name: content['contentName'],
                        type: content['objectType'],
                        lastUpdate: DateTime.parse(
                            content['shareDT'].replaceAll(':', '')),
                        id: content['contentId'])
                      ..download(onlyHeader: true))
                    .toList()))
            .toList(),
      ));
    });
    return Result(true, true);
  }

  /*@override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> tr = super.toJson();
    tr['data'] = data;
    tr['newFlags'] = bachecaNewFlags;
    return tr;
  }*/

  /*@override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    data = json['data'].map((c) => Comunicazione.fromJson(c)).toList();
    bachecaNewFlags = json['newFlags']
        .map<String, bool>((k, v) => MapEntry<String, bool>(k, v));
  }*/
}

abstract class CustomPath {
  final String name;
  bool changed = false;
  CustomDirectory parent;
  CustomPath(this.name);
}

class CustomDirectory extends CustomPath {
  final List<CustomPath> children;

  CustomDirectory({@required String name, @required this.children})
      : super(name) {
    for (CustomPath child in children) {
      child.parent = this;
      changed |= child.changed;
    }
  }

  CustomDirectory view({bool recursive = false}) {
    children
        .where((child) => child is CustomFile || recursive)
        .forEach((child) {
      if (child is CustomDirectory)
        child.view(recursive: true);
      else
        child.changed = false;
    });
    changed = children.any((child) => child.changed);
    return this;
  }
}

class CustomFile extends CustomPath {
  String type, fileName;
  final int id;
  int lastUpdate;

  CustomFile(
      {@required String name,
      @required this.type,
      @required this.id,
      String fileName,
      DateTime lastUpdate})
      : super(name) {
    changed = lastUpdate.millisecondsSinceEpoch > (this.lastUpdate ?? 0);
    this.lastUpdate =
        max(this.lastUpdate ?? 0, lastUpdate.millisecondsSinceEpoch);
  }

  void download({bool onlyHeader = false}) async {
    if (onlyHeader && type != 'file') return;
    Map<String, String> headers = {
      'Z-Dev-Apikey': 'Tg1NWEwNGIgIC0K',
      'Content-Type': 'application/json',
      'User-Agent': 'CVVS/std/1.7.9 Android/6.0',
      'Z-Auth-Token': RegistroApi.token,
    };
    Function funct = onlyHeader ? http.head : http.get;
    http.Response res = await funct(
        'https://web.spaggiari.eu/rest/v1/students/${RegistroApi.usrId}/didactics/item/$id',
        headers: headers);
    if (onlyHeader) {
      fileName = res.headers['content-disposition'];
      fileName = fileName
          .substring(fileName.indexOf('filename=') + 'filename='.length);
      type = fileName.substring(fileName.lastIndexOf('.'));
      return;
    }
    if (type == 'link') launch(jsonDecode(res.body)['item']['link']);
  }
}
