import 'dart:convert';
import 'dart:io';

import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/utils/mapUtils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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
                        id: content['contentId'])
                      ..getType())
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
  CustomDirectory parent;
  final DateTime lastUpdate;
  CustomPath(this.name, {this.lastUpdate});
}

class CustomDirectory extends CustomPath {
  final List<CustomPath> children;
  CustomDirectory(
      {@required String name, @required this.children, DateTime lastUpdate})
      : super(name, lastUpdate: lastUpdate) {
    for (CustomPath child in children) child.parent = this;
  }
}

class CustomFile extends CustomPath {
  String type, fileName;
  final int id;

  CustomFile(
      {@required String name,
      @required this.type,
      @required this.id,
      String fileName,
      DateTime lastUpdate})
      : super(name, lastUpdate: lastUpdate);

  void getType() async {
    if (type != 'file') return;
    Map<String, String> headers = {
      'Z-Dev-Apikey': 'Tg1NWEwNGIgIC0K',
      'Content-Type': 'application/json',
      'User-Agent': 'CVVS/std/1.7.9 Android/6.0',
      'Z-Auth-Token': RegistroApi.token,
    };
    http.Response res = await http.head(
        'https://web.spaggiari.eu/rest/v1/students/${RegistroApi.usrId}/didactics/item/$id',
        headers: headers);
    fileName = res.headers['content-disposition'];
    fileName =
        fileName.substring(fileName.indexOf('filename=') + 'filename='.length);
    type = fileName.substring(fileName.lastIndexOf('.'));
    print('$type -> $fileName');
  }
}
