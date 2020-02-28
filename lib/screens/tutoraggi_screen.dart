import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:flutter/material.dart';

final List<_Tutor> tutors = [
  _Tutor('Amos', 'Lo Verde', '5N', 'INFORMATICA'),
  _Tutor('Giacomo', 'Brognara', '4F', 'INFORMATICA'),
  _Tutor('Pietro', 'Cipriani', '4G', 'INFORMATICA'),
  _Tutor('Ilaria', 'Stanghellini', '5A', 'MATEMATICA'),
  _Tutor('Jacopo', 'Ballarini', '4F', 'MATEMATICA'),
  _Tutor('Alberto', 'Pasotto', '5G', 'MATEMATICA'),
  _Tutor('Pietro', 'Baltieri', '4F', 'FISICA'),
  _Tutor('Jacopo', 'Ballarini', '4F', 'FISICA'),
  _Tutor('Matteo', 'Romano', '5G', 'FISICA'),
  _Tutor('Michele', 'Rossetti', '5G', 'SCIENZE NATURALI'),
  _Tutor('Emma', 'Caloi', '5D', 'INGLESE'),
  _Tutor('Cesare', 'Reggiani', '5G', "DISEGNO - ST. DELL'ARTE"),
];

class _Tutor {
  final String _nome, _cognome, classe, materia;
  _Tutor(this._nome, this._cognome, this.classe, this.materia);
  String get email =>
      '${_nome.replaceAll(' ', '').toLowerCase()}.${_cognome.replaceAll(' ', '').toLowerCase()}@messedaglia.edu.it';
  String get nome => '$_nome $_cognome';
}

class TutoraggiScreen extends StatefulWidget {
  @override
  _TutoraggiScreenState createState() => _TutoraggiScreenState();
}

class _TutoraggiScreenState extends State<TutoraggiScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.black54,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              title: Text(
                'TUTORAGGI',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              elevation: 0,
              pinned: true,
              centerTitle: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: CustomPaint(
                painter: BackgroundPainter(Theme.of(context)),
                size: Size.infinite,
              ),
              bottom: PreferredSize(
                  child: Container(),
                  preferredSize:
                      Size.fromHeight(MediaQuery.of(context).size.width / 8)),
            ),
            SliverList(
                delegate: SliverChildListDelegate(
              tutors
                  .map((tutor) => ListTile(
                        title: Text(tutor.nome, textAlign: TextAlign.center),
                        leading: CircleAvatar(
                          backgroundColor: Globals.subjects[tutor.materia]
                                  ['colore']
                              .withOpacity(0.7),
                          child: Icon(
                            Globals.subjects[tutor.materia]['icona'],
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                          ),
                        ),
                        trailing: Text(tutor.classe),
                        onTap: () => Scaffold.of(context).showSnackBar(SnackBar(
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            content: Text(
                              'Questa SnackBar verrà sostituita dal link a gmail in un prossimo aggiornamento...',
                            ))),
                        subtitle: Text(
                          tutor.email,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ))
                  .toList(),
            ))
          ],
        ),
      ),
    );
  }
}
