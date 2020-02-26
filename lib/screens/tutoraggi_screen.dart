import 'package:flutter/material.dart';
import 'package:http/http.dart';

class TutoraggiScreen extends StatefulWidget {
  @override
  _TutoraggiScreenState createState() => _TutoraggiScreenState();
}

class _TutoraggiScreenState extends State<TutoraggiScreen> {
  _scrape() async {
    var client = Client();
    Response response = await client.get(
        'https://www.messedaglia.edu.it/index.php/studenti/205-index/studenti/2050-tutoraggio-degli-studenti');

    // debugPrint(response.body);

    var document = parse(
        response.body); // FIXME se importo il pacchetto mi da un errore strano
    List<Element> links =
        document.querySelectorAll(".item-page > div:nth-child(3)");

    debugPrint('${links.runtimeType}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: _scrape,
          ),
        ],
      ),
    );
  }
}
