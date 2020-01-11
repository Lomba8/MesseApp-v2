import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Server {
  static String nome, cognome, scuola, compleanno;

  static String _capitalize(String s) {
    s.toLowerCase();
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  static Map<String, String> headers = {
    'Z-Dev-Apikey': 'Tg1NWEwNGIgIC0K',
    'Content-Type': 'application/json',
    'User-Agent': 'CVVS/std/1.7.9Android/6.0'
  };

  static Map<String, String> body = {"ident": null, "pass": '', "uid": ''};

  static String url = 'https://web.spaggiari.eu/rest/v1/auth/login';

  static String _token;

  static Future<bool> login(
      String username, String password, bool check) async {
    print("logging ${username ?? 'null'} ${password ?? 'null'}");
    try {
      body["pass"] = password;
      body["uid"] = username;
      var res = await http.post(url, headers: headers, body: json.encode(body));

      if (res.statusCode == 200) {
        _token = json.decode(res.body)["token"];
        //Globals.setCredentials(_username, _password);
        final prefs = await SharedPreferences.getInstance();
        headers['Z-Auth-Token'] = _token;
        if (!check) return true;

        var card = await http.get(
            "https://web.spaggiari.eu/rest/v1/students/${username.substring(1)}/card",
            headers: headers);
        var data = json.decode(card.body)["card"];

        if (data['schCode'].toString() == 'VRLS0003') {
          await prefs.setString('username', username);
          await prefs.setString('password', password);
          await prefs.setString(
              'scuola',
              scuola =
                  _capitalize("${data["schName"]} ${data["schDedication"]}"));
          await prefs.setString('nome', nome = _capitalize(data["firstName"]));
          await prefs.setString(
              'cognome', cognome = _capitalize(data["lastName"]));
          await prefs.setString(
              'compleanno', compleanno = _capitalize(data["birthDate"]));
          return true;
        }
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future getGrades() {
    //da con node js
  }
}
