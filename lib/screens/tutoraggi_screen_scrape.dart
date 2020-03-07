import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:html/dom.dart' as dom;

class TutoraggiScreenScrape extends StatelessWidget {
  _scrape() async {
    var client = Client();
    Response response = await client.get(
        'https://www.messedaglia.edu.it/index.php/studenti/205-index/studenti/2050-tutoraggio-degli-studenti');

    // var client = Client();
    // Response response = await client.get('https://messe-app.herokuapp.com/');

    var document = parse(response.body);

    dom.Element links = document.querySelector(" .item-380 > a:nth-child(1)");
    debugPrint(links.toString());

    print('informatica');
    print('    1');
    // print(response.body.lastIndexOf('Giacomo Lombardi'));

    //print('Amos\n' + response.body.substring(36670));
    print('    2');

    print('    3');
    //print(response.body.substring(36637));

    print('storia dell\'arte');
    print('    1');
    //print('REggiani' + response.body.substring(48834));

    print('    2');

    print('    3');

    // print(response.body.lastIndexOf('STORIA DELL\'ARTE:'));

    // for (dom.Element link in links) {
    //   debugPrint('${link.innerHtml}');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(icon: Icon(Icons.bug_report), onPressed: _scrape),
      ),
    );
  }
}
