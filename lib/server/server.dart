import 'dart:convert';

import 'package:applicazione_prova/preferences/globals.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Server {
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
        var scuola = await http.get(
            "https://web.spaggiari.eu/rest/v1/students/${prefs.getString('username').substring(1)}/card",
            headers: headers);
        var data = json.decode(scuola.body);
        if (data['schCode'].toString() == 'VRLS0003') print(data['schCode']);
        print(data);
        _isValid = true;
      } else
        _isValid = false;
    } catch (e) {
      print(e);
    }
    return _isValid;
  }

  static Future<bool> scuola() async {
    //final prefs = await SharedPreferences.getInstance();
  }

  Future getGrades() {
    //da con node js
  }
}
