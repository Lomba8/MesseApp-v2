import 'dart:io';

import 'package:applicazione_prova/preferences/globals.dart';
import 'package:applicazione_prova/screens/login_screen.dart';
import 'package:applicazione_prova/screens/map_screen.dart';
import 'package:applicazione_prova/screens/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

//TODO: mettere quando non ce connessione internet https://rive.app/a/atiq31416/files/flare/no-network-available

//TODO: per il caricamento del download usare questo flare con i nomi dei vari stadi delle animazioni da associar alla fase del donload delle circolari
//https://rive.app/a/pollux/files/flare/liquid-download/preview

//TODO: loader https://rive.app/a/chrisob94/files/flare/loader/preview

void main() {
  initializeDateFormatting('it_IT', null).then((_) async {
    Menu menu = Menu();
    LoginScreen loginScreen = LoginScreen();
    WidgetsFlutterBinding.ensureInitialized();
    //TODO: usare per notificare delle releases nuove con packageInfo.version & .buildNumber

    IosDeviceInfo iosInfo;
    AndroidDeviceInfo androidInfo;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    dynamic _mode;
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('DarkMode') == null) {
      try {
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
      }
    } else {
      prefs.getBool('DarkMode')
          ? _mode = ThemeMode.dark
          : _mode = ThemeMode.light;
    }

    print(_mode);

    runApp(
      ChangeNotifierProvider<Globals>(
        create: (_) => Globals(_mode),
        child: MaterialAppWithTheme(menu: menu, loginScreen: loginScreen),
      ),
    );
  });
}

class MaterialAppWithTheme extends StatelessWidget {
  const MaterialAppWithTheme({
    Key key,
    @required this.menu,
    @required this.loginScreen,
  }) : super(key: key);

  final Menu menu;
  final LoginScreen loginScreen;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Globals>(context);
    return MaterialApp(
      theme: Globals.lightTheme,
      darkTheme: Globals.darkTheme,
      themeMode: theme
          .getTheme(),
      debugShowCheckedModeBanner: false,
      title: 'Applicazione di prova',
      initialRoute: LoginScreen.id,
      routes: {
        Menu.id: (context) => menu,
        LoginScreen.id: (context) => loginScreen
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
