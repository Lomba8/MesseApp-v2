import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Globals {
  static final ThemeData lightTheme = ThemeData(
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    pageTransitionsTheme: PageTransitionsTheme(builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder()
    }),
    // Define the default brightness and colors.
    brightness: Brightness.light,

    backgroundColor: Color.fromRGBO(239, 238, 245, 1), // rgb(239, 238, 245, 1)

    scaffoldBackgroundColor: Color.fromRGBO(239, 238, 245, 1),

    primaryColor: Color.fromRGBO(52, 90, 100, 1), // rgb(105, 181, 201, 1)
    /*
    Color.fromRGBO(91, 34, 196,
        1),  (Globals.rosso,). Alternativa a 91,34,19662, 123, 150,)*/

    accentColor: Color.fromRGBO(62, 123, 150, 1), // rgb(62, 123, 150, 1)

    // Define the default font family.
    fontFamily: 'CoreSans',

    // Define the default TextTheme. Use this to specify the default
    // text styling for headlines, titles, bodies of text, and more.
    textTheme: TextTheme(
      headline5: TextStyle(
          fontSize: 72.0,
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(246, 232, 234, 1)),
      headline6: TextStyle(
          fontSize: 36.0,
          fontStyle: FontStyle.italic,
          color: Color.fromRGBO(246, 232, 234, 1)),
      bodyText1: TextStyle(color: Colors.black54),
      bodyText2: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: Color.fromRGBO(0, 0, 0, 1)),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    // Define the default brightness and colors.
    brightness: Brightness.dark,

    backgroundColor: Color.fromRGBO(28, 28, 39, 1), // rgb(28, 28, 39, 1)

    scaffoldBackgroundColor: Color.fromRGBO(28, 28, 39, 1),

    primaryColor: Color.fromRGBO(105, 181, 201, 1), // rgb(105, 181, 201, 1)

    cardColor: Color.fromRGBO(28, 28, 39, 1),
    cardTheme: CardTheme(
      elevation: 0,
    ),
    /*
    Color.fromRGBO(91, 34, 196,
        1),  (Globals.rosso,). Alternativa a 91,34,19662, 123, 150,)*/

    accentColor: Color.fromRGBO(62, 123, 150, 1), // rgb(62, 123, 150, 1)

    // hintColor: Globals.rosso, // da togliere

    // Define the default font family.
    fontFamily: 'CoreSansRounded',

    // Define the default TextTheme. Use this to specify the default
    // text styling for headlines, titles, bodies of text, and more.
    textTheme: TextTheme(
      headline5: TextStyle(
        fontSize: 75,
        fontWeight: FontWeight.bold,
        color: Color.fromRGBO(105, 181, 201, 1),
      ),
      headline6: TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold), // rgb(40, 41, 60, 1)
      bodyText1: TextStyle(color: Colors.white54),
      bodyText2: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: Color.fromRGBO(255, 255, 255, 1)),
    ),
  );

  static Color bluScolorito = Color.fromRGBO(105, 181, 201, 0.5);

  static Color violaScolorito = Color.fromRGBO(115, 121, 247, 0.7);

  static Map<String, Map<String, dynamic>> subjects = {
    "DISEGNO - ST. DELL'ARTE": {
      'colore': Colors.red,
      'icona': Icons.brush,
    },
    "STORIA DELL'ARTE": {
      // per i tutor perche non sono capaci di usare gli stessi nomi che hanno dato a classe viva

      'colore': Colors.red,
      'icona': Icons.brush,
    },
    'FILOSOFIA': {
      'colore': Colors.blue,
      'icona': MdiIcons.yinYang, //yinYang
    },
    'FISICA': {
      'colore': Colors.yellow,
      'icona': MdiIcons.electronFramework, // atom
    },
    'INGLESE': {
      'colore': Colors.lightGreenAccent,
      'icona': MdiIcons.currencyGbp, // or googleTranslate ?
    },
    'INFORMATICA': {
      'colore': Colors.green,
      'icona': Icons.desktop_mac, //  or codeBraces, languageCpp
    },
    'LINGUA E CULTURA LATINA': {
      'colore': Colors.amber,
      'icona': MdiIcons
          .romanNumeral6, // FIXME cosa mettere?  scholl-outline, cash-multiple, currency-usd-off, romanNumeral9?
    },
    'LINGUA E LETTERATURA ITALIANA': {
      'colore': Colors.cyan,
      'icona': MdiIcons.alphabeticalVariant, //
    },
    'MATEMATICA': {
      'colore': Colors.brown,
      'icona': MdiIcons.squareRoot,
    },
    'PROGETTI / POTENZIAMENTO': {
      'colore': Colors.grey,
      'icona': MdiIcons
          .gavel, // FIXME cosa mettere?   weightLifter, bag-personal-outline, foodOff?
    },
    "RELIGIONE-ATTIVITA' ALTERNATIVE": {
      'colore': Colors.deepPurple,
      'icona': MdiIcons.christianity,
    },
    'SCIENZE MOTORIE E SPORTIVE': {
      'colore': Colors.purpleAccent,
      'icona': MdiIcons.basketball,
    },
    'SCIENZE NATURALI': {
      'colore': Colors.tealAccent,
      'icona': MdiIcons.flask, // or dna,
    },
    'SCIENZE': {
      // per i tutor perche non sono capaci di usare gli stessi nomi che hanno dato a classe viva
      'colore': Colors.tealAccent,
      'icona': MdiIcons.flask, // or dna,
    },
    'STORIA': {
      'colore': Colors.deepOrangeAccent,
      'icona': MdiIcons.pillar, // or account_balance
    },
  };

  static Map<String, Icon> icone = {
    // TODO: scegliere icone
    'Alternanza':
        Icon(Icons.headset_mic), // headset_mic, work, home_work, euro, weekend
    'App Panini': Icon(Icons.smartphone),
    'Autogestione': Icon(Icons.map),

    'Bacheca': Icon(Icons
        .markunread_mailbox), // drafts, description, markunread_mailbox, inbox, attach_file, local_post_office, insert_drive_file
    'Note': Icon(Icons.sentiment_dissatisfied), //feedback,

    'Tutoraggi': Icon(Icons
        .person_add), // people, accessibility, how_to_reg, emoji_people, group_add, group, people_outline
  };

  static Color rosso = Color.fromRGBO(79, 20, 17, 1);

  static Map<String, Map<String, dynamic>> sezioni = {
    'arancione': {
      'color': Colors.deepOrangeAccent, //Color.fromRGBO(241, 152, 93, 0.7),
      'textColor': Colors.deepOrangeAccent
          .withOpacity(0.7), //Color.fromRGBO(241, 152, 93, 0.5),
      'gradientColors': [
        Colors.orange[800]
            .withOpacity(0.8), //Color.fromRGBO(238, 142, 84, 1.0),
        Colors.orange[600]
            .withOpacity(0.8), //Color.fromRGBO(242, 158, 104, 1.0),
        Colors.orange[400]
            .withOpacity(0.8), //Color.fromRGBO(246, 193, 156, 1.0),
      ],
    },
    'blu': {
      'color': Color.fromRGBO(92, 130, 247, 0.7),
      'textColor': Color.fromRGBO(92, 130, 247, 0.7),
      'gradientColors': [
        Color.fromRGBO(80, 122, 246, 1.0),
        Color.fromRGBO(110, 146, 247, 1.0),
        Color.fromRGBO(141, 173, 248, 1.0),
      ],
    },
    'rosa': {
      'color': Colors.purpleAccent, //Color.fromRGBO(186, 95, 192, 0.7),
      'textColor': Colors.purpleAccent
          .withOpacity(0.7), //Color.fromRGBO(186, 95, 192, 0.5),
      'gradientColors': [
        Colors.purpleAccent[400]
            .withOpacity(0.8), // Color.fromRGBO(233, 90, 219, 1.0),
        Colors.purpleAccent
            .withOpacity(0.8), // Color.fromRGBO(236, 124, 228, 1.0),
        Colors.purpleAccent[100]
            .withOpacity(0.8), // Color.fromRGBO(239, 163, 233, 1.0),
      ],
    },
    'rosso': {
      'color': Colors.redAccent[400].withOpacity(0.9),
      'textColor': Colors.redAccent[400].withOpacity(0.6),
      'gradientColors': [
        Colors.redAccent[400]
            .withOpacity(0.9), // Color.fromRGBO(236, 77, 69, 1.0),
        Colors.redAccent[400], // Color.fromRGBO(237, 103, 98, 1.0),
        Colors.redAccent, // Color.fromRGBO(239, 135, 132, 1.0),
      ],
    },
    'verde': {
      'color': Color.fromRGBO(144, 237, 137, 0.7),
      'textColor': Color.fromRGBO(72, 118, 63,
          1), // TODO: scegliere un colore, quello di prima non si vedeva con il tema chiaro
      'gradientColors': [
        Color.fromRGBO(21, 195, 65, 1.0),
        Color.fromRGBO(46, 208, 81, 1.0),
        Color.fromRGBO(115, 247, 124, 1.0),
      ],
    },
    'viola': {
      'color': Color.fromRGBO(126, 121, 206, 0.7),
      'textColor': Color.fromRGBO(126, 121, 206, 0.9),
      'gradientColors': [
        Color.fromRGBO(115, 91, 245, 1.0),
        Color.fromRGBO(139, 115, 244, 1.0),
        Color.fromRGBO(162, 137, 247, 1.0),
      ],
    },
  };
}
