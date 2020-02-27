import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:html/dom.dart' as dom;

class TutoraggiScreenScrape extends StatelessWidget {
  _scrape() async {
    var client = Client();
    Response response = await client.get(
        'https://www.messedaglia.edu.it/index.php/studenti/205-index/studenti/2050-tutoraggio-degli-studenti');

    var document = parse(response.body);

    dom.Element links = document.querySelector(
        " .item-page > div:nth-child(3) > p:nth-child(3) > strong:nth-child(1)");
    //debugPrint('${links.innerHtml}');

    print('informatica');
    print('    1');
    // print(response.body.lastIndexOf('INFORMATICA'));

    //print('Amos' + response.body.substring(36637));
    print('    2');
    print('Brognara' + response.body.substring(36647));

    print('    3');
    print(response.body.substring(36637));

    print('storia dell\'arte');
    print(response.body.lastIndexOf('STORIA DELL\'ARTE:'));
    print(response.body.substring(48834));

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
