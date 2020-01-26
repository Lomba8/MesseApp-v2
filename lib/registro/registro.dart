import 'dart:convert';
import 'dart:io';

import 'package:applicazione_prova/registro/agenda_registro_data.dart';
import 'package:applicazione_prova/registro/voti_registro_data.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistroApi {
  static String nome, cognome, scuola, compleanno;
  static int usrId;

  static final VotiRegistroData voti = VotiRegistroData();
  static final AgendaRegistroData agenda = AgendaRegistroData();

  // TODO: gestire parte dei download dall'esterno:
  //  - ignore update requests if already loading         OK
  //  - Z-If-None-Match                                   OK
  //  - lastUpdate
  //  - ecc...

  static String _capitalize(String s) {
    s.toLowerCase();
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  static Map<String, String> body = {"ident": null, "pass": '', "uid": ''};

  static final String loginUrl = 'https://web.spaggiari.eu/rest/v1/auth/login';

  static String token;

  static Future<bool> login(
      String username, String password, bool check) async {
    try {
      Map<String, String> headers = {
        'Z-Dev-Apikey': 'Tg1NWEwNGIgIC0K',
        'Content-Type': 'application/json',
        'User-Agent': 'CVVS/std/1.7.9',
      };
      body["pass"] = password;
      body["uid"] = username;
      var res = await http.post(loginUrl,
          headers: headers, body: json.encode(body));

      if (res.statusCode != 200) return false;
      token = json.decode(res.body)["token"];
      //Globals.setCredentials(_username, _password);
      final prefs = await SharedPreferences.getInstance();
      if (!check) {
        scuola = prefs.getString('scuola');
        nome = prefs.getString('nome');
        cognome = prefs.getString('cognome');
        compleanno = prefs.getString('compleanno');
        usrId = prefs.getInt('usrId');
        return true;
      }
      headers['Z-Auth-Token'] = token;

      var card = await http.get(
          "https://web.spaggiari.eu/rest/v1/students/${username.substring(1)}/card",
          headers: headers);
      var data = json.decode(card.body)["card"];

      if (data['schCode'].toString() == 'VRLS0003') {
        prefs.setString('username', username);
        prefs.setString('password', password);
        prefs.setString(
            'scuola',
            scuola =
                _capitalize("${data["schName"]} ${data["schDedication"]}"));
        prefs.setString('nome', nome = _capitalize(data["firstName"]));
        prefs.setString('cognome', cognome = _capitalize(data["lastName"]));
        prefs.setString(
            'compleanno', compleanno = _capitalize(data["birthDate"]));
        prefs.setInt('usrId', usrId = data["usrId"]);
        return true;
      }
    } catch (e, s) {
      print(e);
      print(s);
    }
    return false;
  }

  static Future<void> downloadAll(void Function(double) callback) async {
    await load();
    int N = 2;
    int n = 0;
    voti.getData().then((ok) => callback(++n / N));
    agenda.getData().then((ok) => callback(++n / N));
  }

  static void save() async {
    Map<String, dynamic> data = {
      'voti': voti.data,
      'votiLastUpdate': voti.lastUpdate,
      'eventi': agenda.data,
      'eventiLastUpdate': agenda.lastUpdate
      // ecc...
    };
    String json = jsonEncode(data);
    Directory dataDir = await getApplicationSupportDirectory();
    File file = File('${dataDir.path}/data.json');
    if (!file.existsSync()) file.createSync();
    file.writeAsStringSync(json, flush: true);
  }

  static void load() async {
    Directory dataDir = await getApplicationSupportDirectory();
    File file = File('${dataDir.path}/data.json');
    if (!file.existsSync()) return;
    Map<String, dynamic> data = jsonDecode(file.readAsStringSync());
    voti.data = data['voti'] ?? {};
    voti.lastUpdate = data['votiLastUpdate'];
    agenda.data = data['eventi'] ?? {};
    agenda.lastUpdate = data['eventiLastUpdate'];
  }
}

abstract class RegistroData {
  DateTime lastUpdate;
  String etag;
  Map data = {};
  final String _url;
  bool _loading = false;

  Future<Result> getData() async {
    if (_loading) return Result(true, false);
    _loading = true;
    Map<String, String> headers = {
      'Z-Dev-Apikey': 'Tg1NWEwNGIgIC0K',
      'Content-Type': 'application/json',
      'User-Agent': 'CVVS/std/1.7.9',
      'Z-Auth-Token': RegistroApi.token,
      'Z-If-None-Match': etag
    };
    http.Response r = await http.get(url, headers: headers);
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

  RegistroData(this._url);

  String get url => _url.replaceFirst('%uid', RegistroApi.usrId.toString());

  Result parseData(dynamic json);
}

class Result {
  final bool ok, reload;
  Result(this.ok, this.reload);
}
