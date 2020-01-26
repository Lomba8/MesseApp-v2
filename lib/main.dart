import 'package:applicazione_prova/preferences/globals.dart';
import 'package:applicazione_prova/screens/login_screen.dart';
import 'package:applicazione_prova/screens/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

//TODO: mettere quando non ce connessione internet https://rive.app/a/atiq31416/files/flare/no-network-available

//TODO: per il caricamento del download usare questo flare con i nomi dei vari stadi delle animazioni da associar alla fase del donload delle circolari
//https://rive.app/a/pollux/files/flare/liquid-download/preview

//TODO: loader https://rive.app/a/chrisob94/files/flare/loader/preview

void main() async {
  initializeDateFormatting('it_IT', null).then((_) {
    print("main");
    Menu menu = Menu();
    LoginScreen loginScreen = LoginScreen();
    runApp(
      MaterialApp(
        theme: Globals.lightTheme,
        darkTheme: Globals.darkTheme,
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        title: 'Applicazione di prova',
        initialRoute: LoginScreen.id,
        routes: {
          Menu.id: (context) => menu,
          LoginScreen.id: (context) => loginScreen
        },
      ),
    );
  });
}

//q bisgna rifare la ruchiesta quando lutente apre la app e/o refersha la page

//TODO: flare_spalsh_screen quando lutente e gia loggato
//https://encrypted-vtbn0.gstatic.com/video?q=tbn:ANd9GcSn0bRM5qNQI4KGQXS0sndsunb3K7glw5dKxphjADZM-xL1Qb1s
//https://pub.dev › packages › flare_splash_screen

//TODO: flare_loading_package

//FIXME: se mi interessa aggiungere lo sblocco con impronta digitale usare questa gif di flare https://rive.app/a/Parth181195/files/flare/material-fingerprint/preview
