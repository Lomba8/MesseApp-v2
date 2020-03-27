import 'dart:convert';
import 'dart:io';

import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/screens/login_screen.dart';
import 'package:Messedaglia/screens/menu_screen.dart';
import 'package:Messedaglia/screens/offline.dart';
import 'package:Messedaglia/utils/db_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:device_info/device_info.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';

//TODO: mettere quando non ce connessione internet https://rive.app/a/atiq31416/files/flare/no-network-available

//TODO: per il caricamento del download usare questo flare con i nomi dei vari stadi delle animazioni da associar alla fase del donload delle circolari
//https://rive.app/a/pollux/files/flare/liquid-download/preview

//TODO: loader https://rive.app/a/chrisob94/files/flare/loader/preview

/*final GoogleSignIn _signIn = GoogleSignIn(
    signInOption: SignInOption.standard,
    scopes: ['https://www.googleapis.com/auth/admin.directory.group.readonly'],
    hostedDomain: 'messedaglia.edu.it');*/

RegistroApi session;

void main() {
  initializeDateFormatting('it_IT', null).then((_) async {
    WidgetsFlutterBinding.ensureInitialized();
    await init();
    session = accounts?.isNotEmpty ?? false ? accounts.first : null;
    //TODO: usare per notificare delle releases nuove con packageInfo.version & .buildNumber
    //_signIn.signIn();
    notificationsPlugin.initialize(
      InitializationSettings(AndroidInitializationSettings('@mipmap/splash'),
          IOSInitializationSettings()),
      onSelectNotification: (payload) async {
        if (notificationCallbacks[payload] == null) return;
        await notificationCallbacks.remove(payload)();
      },
    );

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    prefs = await SharedPreferences.getInstance();
    final PackageInfo pkgInfo = await PackageInfo.fromPlatform();
    appName = pkgInfo.appName;
    appVersion = pkgInfo.version;
    platform = Platform.operatingSystem;
    if (Platform.isAndroid)
      osVersion = (await deviceInfo.androidInfo).version.codename;
    else if (Platform.isIOS)
      osVersion = (await deviceInfo.iosInfo).systemVersion;
    connection_main = await (Connectivity().checkConnectivity());

    //connection_main = Connectivity().onConnectivityChanged;

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
    runApp(RestartWidget(
      child: MaterialAppWithTheme(),
    ));
  });
}

class RestartWidget extends StatefulWidget {
  RestartWidget({this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>().restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

ThemeMode _theme = ThemeMode.dark;
void setTheme(ThemeMode theme) async {
  _currentState.theme = _theme = theme;
  final prefs = await SharedPreferences.getInstance();
  switch (theme) {
    case ThemeMode.dark:
      prefs.setBool('DarkMode', true);
      break;
    case ThemeMode.light:
      prefs.setBool('DarkMode', false);
      break;
    default:
      prefs.setBool('DarkMode', null);
  }
  print(theme.toString());
}

ThemeMode get theme => _theme;

_MaterialAppWithThemeState _currentState;

class MaterialAppWithTheme extends StatefulWidget {
  final Menu menu = Menu();
  final LoginScreen loginScreen = LoginScreen();

  @override
  State<StatefulWidget> createState() =>
      _currentState = _MaterialAppWithThemeState(_theme);
}

class _MaterialAppWithThemeState extends State<MaterialAppWithTheme> {
  ThemeMode _theme;
  _MaterialAppWithThemeState(this._theme);
  set theme(ThemeMode theme) => setState(() => _theme = theme);
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (connection_main == result) return;
      print('NAVIGATOR ' + navigatorKey.currentWidget.toString());
      connection_main = result;
      if (route == 'login_screen') {
        RestartWidget.restartApp(context);
      } else {
        if (result == ConnectivityResult.none) {
          !alreadyPushed
              ? navigatorKey.currentState
                  .push(MaterialPageRoute(builder: (context) => Offline()))
              : print(alreadyPushed);
        } else if (alreadyPushed) {
          alreadyPushed = false;
          navigatorKey.currentState.pop(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Globals.lightTheme,
      navigatorKey: navigatorKey,
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

void saveData(dynamic json, String path) async {
  json = jsonEncode(json);
  Directory dataDir = await getApplicationSupportDirectory();
  File file = File('${dataDir.path}/$path.json');
  if (!file.existsSync()) file.createSync();
  file.writeAsStringSync(json, flush: true);
}

Future<dynamic> loadData(String path) async {
  Directory dataDir = await getApplicationSupportDirectory();
  File file = File('${dataDir.path}/$path.json');
  if (!file.existsSync()) return null;
  return jsonDecode(file.readAsStringSync());
}

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();
final Map<String, Future<dynamic> Function()> notificationCallbacks = {};
SharedPreferences prefs;

ConnectivityResult connection;
String appName, appVersion, platform, osVersion, route;
bool alreadyPushed = false;
var subscription;
dynamic connection_main;
//q bisgna rifare la ruchiesta quando lutente apre la app e/o refersha la page

//TODO: flare_spalsh_screen quando lutente e gia loggato
//https://encrypted-vtbn0.gstatic.com/video?q=tbn:ANd9GcSn0bRM5qNQI4KGQXS0sndsunb3K7glw5dKxphjADZM-xL1Qb1s
//https://pub.dev › packages › flare_splash_screen

//TODO: flare_loading_package

//FIXME: se mi interessa aggiungere lo sblocco con impronta digitale usare questa gif di flare https://rive.app/a/Parth181195/files/flare/material-fingerprint/preview
