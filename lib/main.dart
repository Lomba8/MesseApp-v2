import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/screens/login_screen.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:device_info/device_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

//TODO: mettere quando non ce connessione internet https://rive.app/a/atiq31416/files/flare/no-network-available

//TODO: per il caricamento del download usare questo flare con i nomi dei vari stadi delle animazioni da associar alla fase del donload delle circolari
//https://rive.app/a/pollux/files/flare/liquid-download/preview

//TODO: loader https://rive.app/a/chrisob94/files/flare/loader/preview

/*final GoogleSignIn _signIn = GoogleSignIn(
    signInOption: SignInOption.standard,
    scopes: ['https://www.googleapis.com/auth/admin.directory.group.readonly'],
    hostedDomain: 'messedaglia.edu.it');*/

void main() {
  initializeDateFormatting('it_IT', null).then((_) async {
    Menu menu = Menu();
    LoginScreen loginScreen = LoginScreen();
    WidgetsFlutterBinding.ensureInitialized();
    //TODO: usare per notificare delle releases nuove con packageInfo.version & .buildNumber
    //_signIn.signIn();
    IosDeviceInfo iosInfo;
    AndroidDeviceInfo androidInfo;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('DarkMode') == null) {
      _theme = ThemeMode
          .dark; // TODO: temporaneamente il cambio tema è stato soppresso per futuro spostamento nelle impostazioni
      /*try {
        if (Platform.isAndroid) {
          androidInfo = await deviceInfo.androidInfo;
        } else if (Platform.isIOS) {
          iosInfo = await deviceInfo.iosInfo;
          if (double.parse(iosInfo.systemVersion.replaceAll(RegExp('\D'), '')) <
              13.0) {
            _mode = ThemeMode.dark;
            prefs.setBool('DarkMode', true);
          } else {
            _mode = ThemeMode.system;
          }
        }
      } on PlatformException {
        print('Error: Failed to get platform version.');
      }*/
    } else {
      prefs.getBool('DarkMode')
          ? _theme = ThemeMode.dark
          : _theme = ThemeMode.light;
    }
    print(_theme);
    runApp(MaterialAppWithTheme(menu: menu, loginScreen: loginScreen));
  });
}

ThemeMode _theme = ThemeMode.dark;
void setTheme (ThemeMode theme) async {
  _currentState.theme = _theme = theme;
  final prefs = await SharedPreferences.getInstance();
  switch (theme) {
    case ThemeMode.dark: prefs.setBool('DarkMode', true); break;
    case ThemeMode.light: prefs.setBool('DarkMode', false); break;
    default: prefs.setBool('DarkMode', null);
  }
    print(theme.toString());
}
_MaterialAppWithThemeState _currentState;

class MaterialAppWithTheme extends StatefulWidget {
  const MaterialAppWithTheme({
    Key key,
    @required this.menu,
    @required this.loginScreen,
  }) : super(key: key);

  final Menu menu;
  final LoginScreen loginScreen;

  @override
  State<StatefulWidget> createState() => _currentState = _MaterialAppWithThemeState(_theme);
}

class _MaterialAppWithThemeState extends State<MaterialAppWithTheme> {
  ThemeMode _theme;
  _MaterialAppWithThemeState (this._theme);
  set theme (ThemeMode theme) => setState(() => _theme = theme);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Globals.lightTheme,
      darkTheme: Globals.darkTheme,
      themeMode: _theme,
      debugShowCheckedModeBanner: false,
      title: 'Applicazione di prova',
      initialRoute: LoginScreen.id,
      routes: {
        Menu.id: (context) => widget.menu,
        LoginScreen.id: (context) => widget.loginScreen
      },
      //home: MapScreen(),
    );
  }

}

//q bisgna rifare la ruchiesta quando lutente apre la app e/o refersha la page

//TODO: flare_spalsh_screen quando lutente e gia loggato
//https://encrypted-vtbn0.gstatic.com/video?q=tbn:ANd9GcSn0bRM5qNQI4KGQXS0sndsunb3K7glw5dKxphjADZM-xL1Qb1s
//https://pub.dev › packages › flare_splash_screen

//TODO: flare_loading_package

//FIXME: se mi interessa aggiungere lo sblocco con impronta digitale usare questa gif di flare https://rive.app/a/Parth181195/files/flare/material-fingerprint/preview
