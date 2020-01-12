import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Server {
  static String nome, cognome, scuola, compleanno;
  static int usrId;

  static Map voti = {};
  static int votiLastUpdate;

  static String _capitalize(String s) {
    s.toLowerCase();
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  static Map<String, String> headers = {
    'Z-Dev-Apikey': 'Tg1NWEwNGIgIC0K',
    'Content-Type': 'application/json',
    'User-Agent': 'CVVS/std/1.7.9'
  };

  static Map<String, String> body = {"ident": null, "pass": '', "uid": ''};

  static final String loginUrl = 'https://web.spaggiari.eu/rest/v1/auth/login';
  static final String votiUrl =
      'https://web.spaggiari.eu/rest/v1/students/%d/grades2';

  static String _token;

  static Future<bool> login(String username, String password, bool check) async {
    try {
      body["pass"] = password;
      body["uid"] = username;
      var res =
          await http.post(loginUrl, headers: headers, body: json.encode(body));

      if (res.statusCode != 200) return false;
      _token = json.decode(res.body)["token"];
      //Globals.setCredentials(_username, _password);
      final prefs = await SharedPreferences.getInstance();
      headers['Z-Auth-Token'] = _token;
      if (!check) {
        scuola = prefs.getString('scuola');
        nome = prefs.getString('nome');
        cognome = prefs.getString('cognome');
        compleanno = prefs.getString('compleanno');
        usrId = prefs.getInt('usrId');
        return true;
      }

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
    } catch (e) {
      print(e);
    }
    return false;
  }

  static Future<bool> getVoti() async {
    // TODO: gestire Z-If-None-Match
    try {
      var r = await http.get(votiUrl.replaceFirst('%d', usrId.toString()), headers: headers);
      if (r.statusCode != 200) return false;
      var data = json.decode(r.body)['grades'];

      (data as List).forEach((m) {
        if (m['canceled']) return;
        Map subject = voti[m['subjectId']] ??= {
          'subjectCode': m['subjectCode'],  // nome abbreviato
          'subjectDesc': m['subjectDesc'],  // nome completo
          'periodi': []
        };
        List votiPeriodo = subject[m['periodDesc'].toUpperCase()];
        if (votiPeriodo == null) {
          votiPeriodo = subject[m['periodDesc'].toUpperCase()] = [];
          subject['periodi'].add(m['periodDesc'].toUpperCase());
        }
        votiPeriodo.add({
          'data': m['evtDate'],
          'voto': m['decimalValue'],
          'votoStr': m['displayValue'],
          'ordine': m['displaPos'],
          'info': m['notesForFamily'],
        });
      });
      voti.forEach((key, value) {
        value['TOTALE'] ??= [];
        value['periodi'].forEach ((p) {
          (value['TOTALE'] as List).addAll(value[p]);
          value[p].sort((a, b) => (a['ordine'] - b['ordine']) as int);
        });
        value['TOTALE'].sort((a, b) => (a['ordine'] - b['ordine']) as int);
      });
      votiLastUpdate = DateTime.now().millisecondsSinceEpoch;
      return true;
    } catch (Exception) {
      print(Exception);
    }
    return false;
  }
}
