import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Globals with ChangeNotifier {
  ThemeMode _themeMode;

  Globals(this._themeMode);
  getTheme() => _themeMode;
  setTheme(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();

    (mode == ThemeMode.dark)
        ? prefs.setBool('DarkMode', true)
        : prefs.setBool('DarkMode', false);

    if (mode == ThemeMode.system) prefs.setBool('DarkMode', null);

    print(mode.toString());

    notifyListeners();
  }

  static final ThemeData lightTheme = ThemeData(
    pageTransitionsTheme: PageTransitionsTheme(builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder()
    }),
    // Define the default brightness and colors.
    brightness: Brightness.light,

    backgroundColor: Color.fromRGBO(239, 238, 245, 1), // rgb(239, 238, 245, 1)

    scaffoldBackgroundColor: Color.fromRGBO(239, 238, 245, 1),

    primaryColor: Color.fromRGBO(105, 181, 201, 1), // rgb(105, 181, 201, 1)
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
        fontSize: 72.0,
        fontWeight: FontWeight.bold,
        color: Color.fromRGBO(105, 181, 201, 1),
      ),
      headline6: TextStyle(
          fontSize: 36.0,
          fontStyle: FontStyle.italic,
          color: Color.fromRGBO(40, 41, 60, 1)), // rgb(40, 41, 60, 1)
      bodyText1: TextStyle(
        color: Colors.white54
      ),
      bodyText2: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: Color.fromRGBO(255, 255, 255, 1)),
    ),
  );

  static Color bluScolorito = Color.fromRGBO(105, 181, 201, 0.5);

  static Color violaScolorito = Color.fromRGBO(115, 121, 247, 0.7);

  static Map<String, Icon> icone = {
    'Autogestione': Icon(Icons.map), // TODO: scegliere icone
    'Alternanza':
        Icon(Icons.headset_mic), // headset_mic, work, home_work, euro, weekend
    'Bacheca': Icon(Icons
        .markunread_mailbox), // drafts, description, markunread_mailbox, inbox, attach_file, local_post_office, insert_drive_file
    'Tutoraggi': Icon(Icons
        .person_add), // people, accessibility, how_to_reg, emoji_people, group_add, group, people_outline
    'Note': Icon(Icons.sentiment_dissatisfied), //feedback,
    'App Panini': Icon(Icons.smartphone),
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
      'textColor': Color.fromRGBO(144, 237, 137, 0.5),
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
