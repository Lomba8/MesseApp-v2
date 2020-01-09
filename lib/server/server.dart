import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Server {
  static String nome, cognome, scuola, compleanno;

  String _capitalize(String s) {
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

  var _res, _body, _token;
  bool _isValid;
  String _username, _password;
  Server(this._username, this._password) {
    if (_username != null && _password != null) {
      body['uid'] = _username;
      body['pass'] = _password;
      _body = jsonEncode(body);
    }
  }
  Future<bool> login() async {
    try {
      _res = await http.post(url, headers: headers, body: _body);

      if (_res.statusCode == 200) {
        _token = json.decode(_res.body)["token"];
        //Globals.setCredentials(_username, _password);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', _username);
        await prefs.setString('password', _password);
        headers['Z-Auth-Token'] = _token;
        var card = await http.get(
            "https://web.spaggiari.eu/rest/v1/students/${prefs.getString('username').substring(1)}/card",
            headers: headers);
        var data = json.decode(card.body)["card"];
        print(data);
        if (data['schCode'].toString() == 'VRLS0003') {
          _isValid = true;

          nome = _capitalize(data["firstName"]);
          cognome = _capitalize(data["lastName"]);
          scuola = _capitalize("${data["schName"]} ${data["schDedication"]}");
          compleanno = _capitalize(data["birthDate"]);
          await prefs.setString('scuola', scuola);
          await prefs.setString('nome', nome);
          await prefs.setString('cognome', cognome);
          await prefs.setString('compleanno', compleanno);
        }
      } else
        _isValid = false;
    } catch (e) {
      print(e);
    }
    return _isValid;
  }

  Future getGrades() {
    //da con node js
  }
}
