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
    'INGLESE POTENZIATO': {
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
          .sleep, // FIXME cosa mettere?   weightLifter, bag-personal-outline, foodOff?
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
    'EDUCAZIONE CIVICA': {
      'colore': Colors.pink,
      'icona': MdiIcons.gavel, // or account_balance
    },
  };

  static getMaterieSHort(String nome) {
    switch (nome) {
      case "EDUCAZIONE CIVICA":
        return 'EDU. CIV.';
      case "DISEGNO - ST. DELL'ARTE":
        return 'ARTE';
      case "LINGUA E LETTERATURA ITALIANA":
        return 'ITA';
      case "LINGUA E LETTERATURA LATINA":
        return 'LAT';
      case "PROGETTI / POTENZIAMENTO":
        return 'POTENZIAMENTO';
      case "SCIENZE MOTORIE E SPORTIVE":
        return 'MOTORIA';
      case "SCIENZE NATURALI":
        return 'SCIENZE';
      case "INGLESE POTENZIATO":
        return 'INGL POT.';
      case "INGLESE":
        return 'INGL';
      case "INFORMATICA":
        return 'INFO';
      case "FILOSOFIA":
        return 'FILO';
      case "MATEMATICA":
        return 'MATE';
      case "STORIA":
        return 'STO';
      default:
        return nome;
    }
  }

  static Map<String, Icon> iconeAreaStudenti = {
    // TODO: scegliere icone
    'Alternanza':
        Icon(Icons.headset_mic), // headset_mic, work, home_work, euro, weekend
    'Giustificazioni': Icon(MdiIcons.calendarAlert, size: 35), //transitTransfer
    'Autogestione': Icon(Icons.map),

    'Bacheca': Icon(Icons.markunread_mailbox,
        size:
            28), // drafts, description, markunread_mailbox, inbox, attach_file, local_post_office, insert_drive_file
    'Note': Icon(Icons.sentiment_dissatisfied, size: 35), //feedback,

    'Tutoraggi': Icon(Icons.person_add,
        size:
            30), // people, accessibility, how_to_reg, emoji_people, group_add, group, people_outline

    'Didattica': Icon(MdiIcons.fileMultiple,
        size:
            28), //  fileMultiple, folderAccount, folderMultiple, folderSearch, fileDocumentEdit, folderEdit,
    'Lezioni': Icon(MdiIcons.clipboardEdit, size: 30),
  };
  static Map<String, IconData> iconeNote = {
    'NTWN': MdiIcons.alert,
    'NTTE': MdiIcons.whistle,
    'NTCL': MdiIcons.handcuffs,
    'NTST': MdiIcons.graveStone,
  };

  static Map<String, Color> coloriNote = {
    'NTWN': Colors.yellow,
    'NTTE': Colors.yellow[800],
    'NTCL': Colors.deepOrange,
    'NTST': Colors.redAccent[700],
  };

  static Map<String, IconData> iconeAssenze = {
    'Motivi di salute': MdiIcons.stethoscope,
    'Motivi di famiglia': MdiIcons.accountGroup,
    'Altri motivi': MdiIcons.help,
    'Problemi di trasporto / traffico': MdiIcons.busClock,
    'Sciopero': MdiIcons.earth,
    'Ritardo Breve': MdiIcons.alarmBell,
    '': MdiIcons.help,
  };

  static Map<String, Color> coloriAssenze = {
    'ABA0': Colors.red,
    'ABR0': Colors.orange,
    'ABU0': Colors.yellow,
    'ABR1': Colors.amber
  };

  static Map<String, Map> estensioni = {
    'pdf': {'icona': MdiIcons.filePdf, 'colore': Color(0xFFCA1B00)},
    '.pdf': {'icona': MdiIcons.filePdf, 'colore': Color(0xFFCA1B00)},
    '.odt': {'icona': MdiIcons.fileWord, 'colore': Color(0xFF295492)},
    '.docx': {'icona': MdiIcons.fileWord, 'colore': Color(0xFF295492)},
    '.pages': {'icona': MdiIcons.fileWord, 'colore': Color(0xFF295492)},
    '.zip': {'icona': MdiIcons.fileWord, 'colore': Color(0xFF295492)},

    'msword': {'icona': MdiIcons.fileWord, 'colore': Color(0xFF295492)},
    'vnd.openxmlformats-officedocument.wordprocessingml.document': {
      'icona': MdiIcons.fileWord,
      'colore': Color(0xFF295492)
    },
    'vnd.oasis.opendocument.text': {
      'icona': MdiIcons.fileWord,
      'colore': Color(0xFF295492)
    },
    '.txt': {'icona': MdiIcons.fileWord, 'colore': Color(0xFF295492)},
    '.rtf': {'icona': MdiIcons.fileWord, 'colore': Color(0xFF295492)},
    '.doc': {'icona': MdiIcons.fileWord, 'colore': Color(0xFF295492)},
    '.xls': {'icona': MdiIcons.fileExcel, 'colore': Color(0xFF1C6D42)},
    '.xlsx': {'icona': MdiIcons.fileExcel, 'colore': Color(0xFF1C6D42)},
    '.xlsm': {'icona': MdiIcons.fileExcel, 'colore': Color(0xFF1C6D42)},
    '.numbers': {'icona': MdiIcons.fileExcel, 'colore': Color(0xFF1C6D42)},
    'vnd.ms-office': {'icona': MdiIcons.fileExcel, 'colore': Color(0xFF1C6D42)},
    '.pptx': {'icona': MdiIcons.filePowerpoint, 'colore': Color(0xFFCA4223)},
    '.ppt': {'icona': MdiIcons.filePowerpoint, 'colore': Color(0xFFCA4223)},
    '.odp': {'icona': MdiIcons.filePowerpoint, 'colore': Color(0xFFCA4223)},
    '.pps': {'icona': MdiIcons.filePowerpoint, 'colore': Color(0xFFCA4223)},
    '.pp': {'icona': MdiIcons.filePowerpoint, 'colore': Color(0xFFCA4223)},
    '.key': {'icona': MdiIcons.filePowerpoint, 'colore': Color(0xFFCA4223)},
    'vnd.ms-powerpoint': {
      'icona': MdiIcons.filePowerpoint,
      'colore': Color(0xFFCA4223)
    },

    // '.zip': {'icona': MdiIcons.folderZipOutline, 'colore': Color(0xFFF5AE15)}, //  in relata è un .docx
    '.rar': {'icona': MdiIcons.folderZipOutline, 'colore': Color(0xFFF5AE15)},
    '.aif': {'icona': Icons.audiotrack, 'colore': Color(0xFF009AEF)},
    '.mp3': {'icona': Icons.audiotrack, 'colore': Color(0xFF009AEF)},
    '.wav': {'icona': Icons.audiotrack, 'colore': Color(0xFF009AEF)},
    '.mp4': {'icona': MdiIcons.fileVideoOutline, 'colore': Color(0xFF12AB9B)},
    '.avi': {'icona': MdiIcons.fileVideoOutline, 'colore': Color(0xFF12AB9B)},
    '.mov': {'icona': MdiIcons.fileVideoOutline, 'colore': Color(0xFF12AB9B)},
    '.c': {'icona': MdiIcons.languageC, 'colore': Color(0xFF0074C2)},
    '.h': {'icona': MdiIcons.languageC, 'colore': Color(0xFF0074C2)},
    '.hpp': {'icona': MdiIcons.languageCpp, 'colore': Color(0xFF0074C2)},
    '.cpp': {'icona': MdiIcons.languageCpp, 'colore': Color(0xFF0074C2)},
    '.java': {'icona': MdiIcons.languageJava, 'colore': Color(0xFF53829F)},
    '.class': {'icona': MdiIcons.languageJava, 'colore': Color(0xFF53829F)},
    '.sql': {'icona': MdiIcons.database, 'colore': Color(0xFF3295D5)},
    '.html': {'icona': MdiIcons.languageHtml5, 'colore': Color(0xFFDE4B25)},
    '.css': {'icona': MdiIcons.languageCss3, 'colore': Color(0xFF3596D0)},
    '.js': {'icona': MdiIcons.languageJavascript, 'colore': Color(0xFFf0D91D)},
    '.jpg': {'icona': MdiIcons.fileImage, 'colore': Color(0xAE4BF01D)},
    '.png': {'icona': MdiIcons.fileImage, 'colore': Color(0xAE4BF01D)},
    '.jpeg': {'icona': MdiIcons.fileImage, 'colore': Color(0xAE4BF01D)},
    '.gif': {'icona': MdiIcons.fileImage, 'colore': Color(0xAE4BF01D)},
    '.heif': {'icona': MdiIcons.fileImage, 'colore': Color(0xAE4BF01D)},
    '.ico': {'icona': MdiIcons.fileImage, 'colore': Color(0xAE4BF01D)},
    '.webp': {'icona': MdiIcons.fileImage, 'colore': Color(0xAE4BF01D)},
    '.jpg': {'icona': MdiIcons.fileImage, 'colore': Color(0xAE4BF01D)},
    '.jpeg': {'icona': MdiIcons.fileImage, 'colore': Color(0xAE4BF01D)},
    '.png': {'icona': MdiIcons.fileImage, 'colore': Color(0xAE4BF01D)},
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
