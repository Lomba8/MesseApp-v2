import 'package:flutter/material.dart';

class Globals with ChangeNotifier {
  ThemeMode _themeMode;

  Globals(this._themeMode);
  getTheme() => _themeMode;
  setTheme(ThemeMode mode) {
    _themeMode = mode;
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

    primaryColor: Color.fromRGBO(115, 121, 247, 1), // rgb(115, 121, 247, 1)

    accentColor: Color.fromRGBO(237, 117, 190, 1),

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
          color: Color.fromRGBO(246, 232, 234, 1)),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
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
      bodyText2: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: Color.fromRGBO(255, 255, 255, 1)),
    ),
  );

  static Color bluScolorito = Color.fromRGBO(105, 181, 201, 0.5);

  static Color violaScolorito = Color.fromRGBO(115, 121, 247, 0.7);

  static Color rosso = Color.fromRGBO(79, 20, 17, 1);
}
