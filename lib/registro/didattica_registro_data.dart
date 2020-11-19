import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:Messedaglia/registro/registro.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Messedaglia/main.dart' as main;

import 'bacheca_registro_data.dart';

class DidatticaRegistroData extends RegistroData {
  DidatticaRegistroData({@required RegistroApi account})
      : super(
            url: 'https://web.spaggiari.eu/rest/v1/students/%uid/didactics',
            account: account,
            name: 'didactics');

  @override
  Future<Result> parseData(json) async {
    json = json['didacticts'];
    CustomDirectory data2 =
        CustomDirectory(name: '/', children: {}, account: account);

    json.forEach((teacher) {
      data2.add(
          teacher['teacherName'],
          CustomDirectory(
            name: teacher['teacherName'],
            account: account,
            children: Map.fromEntries(teacher['folders']
                .map<MapEntry<String, CustomPath>>((folder) => MapEntry<String,
                        CustomPath>(
                    folder['folderName'],
                    CustomDirectory(
                        name: folder['folderName'],
                        account: account,
                        children: Map.fromEntries(folder['contents']
                            .map<MapEntry<String, CustomPath>>(
                                (content) => MapEntry<String, CustomPath>(
                                    content['contentName'],
                                    CustomFile(
                                      name: content['contentName'],
                                      type: content['objectType'],
                                      lastUpdate: DateTime.parse(
                                          content['shareDT']
                                              .replaceAll(':', '')),
                                      id: content['contentId'],
                                      oldLastUpdate: data is CustomDirectory
                                          ? data?.getFile(<String>[
                                              teacher['teacherName'],
                                              folder['folderName'],
                                              content['contentName']
                                            ])?.lastUpdate
                                          : null,
                                      account: account,
                                    )..download(onlyHeader: true).then((_) {})))
                            .toList()))))
                .toList()),
          ));
    });
    data = data2;
    return Result(true, true);
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> tr = super.toJson();
    tr['data'] = data;
    return tr;
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    data = CustomDirectory.parse(
        json: json['data'], name: 'dir:/', account: account);
  }

  int get newDidattica => data;

  @override
  Future<void> create() {
    // TODO: implement create
  }
}

abstract class CustomPath {
  final String name;
  bool changed = false;
  CustomDirectory parent;
  final RegistroApi account;

  CustomPath(this.name, {@required this.account});

  Iterable<String> getPath() sync* {
    if (parent != null) yield* parent.getPath();
    yield name;
  }
}

class CustomDirectory extends CustomPath {
  final Map<String, CustomPath> children;

  CustomDirectory(
      {@required String name,
      @required this.children,
      @required RegistroApi account})
      : super(name, account: account) {
    for (CustomPath child in children.values) {
      child.parent = this;
      changed |= child.changed;
    }
  }

  CustomDirectory.parse(
      {@required String name,
      @required Map json,
      @required RegistroApi account})
      : children = json.map((name, file) => MapEntry(
            name.substring(name.indexOf(':') + 1),
            name.startsWith('dir:')
                ? CustomDirectory.parse(
                    name: name, json: file, account: account)
                : CustomFile.parse(name: name, json: file, account: account))),
        super(name.substring('dir:'.length), account: account) {
    for (CustomPath child in children.values) {
      child.parent = this;
      changed |= child.changed;
    }
  }

  CustomPath getFile(Iterable<String> paths) {
    if (paths.first == name) paths.skip(1);
    CustomPath file = this;
    for (String path in paths) {
      if (file == null || file is CustomFile) return null;
      file = (file as CustomDirectory).children[path];
    }
    return file;
  }

  void add(String name, CustomPath child) {
    children[name] = child..parent = this;
  }

  CustomDirectory view({bool recursive = false}) {
    children.values
        .where((child) => child is CustomFile || recursive)
        .forEach((child) {
      if (child is CustomDirectory)
        child.view(recursive: true);
      else
        child.changed = false;
    });
    changed = children.values.any((child) => child.changed);
    return this;
  }

  dynamic toJson() => children.map((name, child) =>
      MapEntry((child is CustomDirectory ? 'dir:' : 'file:') + name, child));
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
      int oldLastUpdate,
      DateTime lastUpdate,
      @required RegistroApi account})
      : super(name, account: account) {
    changed = lastUpdate.millisecondsSinceEpoch > (oldLastUpdate ?? 0);
    this.lastUpdate =
        max(oldLastUpdate ?? 0, lastUpdate.millisecondsSinceEpoch);
  }

  dynamic toJson() =>
      {'type': type, 'fileName': fileName, 'id': id, 'lastUpdate': lastUpdate};

  CustomFile.parse({String name, Map json, @required RegistroApi account})
      : type = json['type'],
        fileName = json['fileName'],
        id = json['id'],
        lastUpdate = json['lastUpdate'],
        super(name.substring('file:'.length), account: account);

  Future<dynamic> download({bool onlyHeader = false}) async {
    if (onlyHeader && type != 'file') return;

    Directory dir = await getApplicationDocumentsDirectory();
    Directory didacticsDir = await Directory('${dir.path}/didactics').create();
    didacticsDir =
        await Directory('${didacticsDir.path}/${main.session.usrId}').create();

    Map<String, String> headers = {
      'Z-Dev-Apikey': 'Tg1NWEwNGIgIC0K',
      'Content-Type': 'application/json',
      'User-Agent': 'CVVS/std/1.7.9 Android/6.0',
      'Z-Auth-Token': account.token,
    };

    Function funct = onlyHeader ? http.head : http.get;
    http.Response res;

    if (funct == http.head ||
        funct == http.get &&
            !File('/${didacticsDir.path}/${encodePath(name: fileName)}')
                .existsSync()) {
      try {
        res = await funct(
            'https://web.spaggiari.eu/rest/v1/students/${account.usrId}/didactics/item/$id',
            headers: headers);
      } catch (e) {
        throw (e);
      }
    }

    if (onlyHeader) {
      fileName = res.headers['content-disposition'];
      fileName = fileName
          .substring(fileName.indexOf('filename=') + 'filename='.length);
      try {
        type = fileName.substring(fileName.lastIndexOf('.'));
      } catch (e) {
        type = res.headers['content-type'].split('/')[1];
      }
      return;
    } else {
      if (type == 'link') {
        launch(jsonDecode(res.body)['item']['link']);
      } else {
        File file = File('/${didacticsDir.path}/${encodePath(name: fileName)}');
        if (!file.existsSync()) await file.writeAsBytes(res.bodyBytes);
        return file.path;
      }
    }
  }
}
