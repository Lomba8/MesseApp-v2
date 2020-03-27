import 'dart:math';

import 'package:Messedaglia/main.dart';
import 'package:Messedaglia/widgets/expansion_sliver.dart';
import 'package:android_intent/android_intent.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Preferences extends StatefulWidget {
  @override
  _PreferencesState createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  bool _darkTheme = theme == ThemeMode.dark;

  @override
  Widget build(BuildContext context) => Material(
      color: Theme.of(context).backgroundColor,
      child: CustomScrollView(slivers: <Widget>[
        ExpansionSliver(
          ExpansionSliverDelegate(context,
              title: 'IMPOSTAZIONI',
              leading: Icons.arrow_back_ios,
              leadingCallback: () {
                Navigator.pop(context);
              },
              action: MdiIcons.license,
              actionCallback: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LicensePage(
                              applicationName: appName,
                            )),
                  ),
              body: _Header()),
        ),
        SliverFillRemaining(
          child: Column(
            children: <Widget>[
              ListTile(
                  title: Text('Tema scuro:'),
                  trailing: Switch(
                    value: _darkTheme,
                    onChanged: (ok) => setState(() {
                      _darkTheme = ok;
                      setTheme(ok ? ThemeMode.dark : ThemeMode.light);
                    }),
                  ))
            ],
          ),
        )
      ]));
}

class _Header extends ResizableWidget {
  final TapGestureRecognizer _websiteTap = TapGestureRecognizer()
    ..onTap = () => AndroidIntent(
            action: 'action_view', data: 'https://www.messedaglia.edu.it')
        .launch();
  final TapGestureRecognizer _supportTap = TapGestureRecognizer()
    ..onTap = () => AndroidIntent(
            action: 'action_view',
            data:
                'mailto:messeapp@messedaglia.edu.it?subject=FEEDBACK MESSEAPP&body=$appName ($appVersion) running on $platform $osVersion')
        .launch();
  final TapGestureRecognizer _bugsTap = TapGestureRecognizer()
    ..onTap = () => AndroidIntent(
        action: 'action_view',
        data: 'https://github.com/Lomba8/MesseApp-v2/issues');

  @override
  Widget build(BuildContext context, [double heightFactor]) => Container(
        height:
            interpolate(minExtent(context), maxExtent(context), heightFactor),
        child: Stack(
          children: [
            Positioned(
              height: interpolate(kToolbarHeight,
                  MediaQuery.of(context).size.width / 2, heightFactor),
              width: interpolate(kToolbarHeight + 40,
                  MediaQuery.of(context).size.width, heightFactor),
              child: Container(
                padding: EdgeInsets.all(interpolate(0.0, 20.0, heightFactor)),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: interpolate(
                        Theme.of(context).primaryColor.withOpacity(0),
                        Theme.of(context).primaryColor,
                        heightFactor),
                    shape: BoxShape.circle),
                child: Image.asset(
                  'images/logomesse_scuro.png',
                  color: interpolate(Theme.of(context).primaryColor,
                      Theme.of(context).backgroundColor, heightFactor),
                  colorBlendMode: BlendMode.xor,
                ),
              ),
            ),
            Positioned(
              top: interpolate(
                  0.0, MediaQuery.of(context).size.width / 2, heightFactor),
              height:
                  interpolate(kToolbarHeight, kTextTabBarHeight, heightFactor),
              left: interpolate(kToolbarHeight + 40, 0.0, heightFactor),
              right: 0,
              child: Center(
                child: RichText(
                  text: TextSpan(
                      text: '$appName  ',
                      style: Theme.of(context).textTheme.bodyText2,
                      children: [
                        TextSpan(
                            text: '($appVersion)',
                            style: Theme.of(context).textTheme.bodyText1)
                      ]),
                ),
              ),
            ),
            Positioned(
              height: kTextTabBarHeight,
              left: 15 -
                  interpolate(MediaQuery.of(context).size.width, 0.0,
                      max(0, min(1, heightFactor * 10 - 6.6))),
              right: 15 +
                  interpolate(MediaQuery.of(context).size.width, 0.0,
                      max(0, min(1, heightFactor * 10 - 6.6))),
              top: (MediaQuery.of(context).size.width / 2 + kTextTabBarHeight) *
                  min(1, heightFactor + 0.24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text('WEBSITE:',
                        style: Theme.of(context).textTheme.bodyText1),
                  ),
                  RichText(
                      textAlign: TextAlign.end,
                      text: TextSpan(
                          text: 'www.messedaglia.edu.it',
                          recognizer: _websiteTap,
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              decoration: TextDecoration.underline)))
                ],
              ),
            ),
            Positioned(
              height: kTextTabBarHeight,
              left: 15 -
                  interpolate(MediaQuery.of(context).size.width, 0.0,
                      max(0, min(1, heightFactor * 10 - 7.8))),
              right: 15 +
                  interpolate(MediaQuery.of(context).size.width, 0.0,
                      max(0, min(1, heightFactor * 10 - 7.8))),
              top: (MediaQuery.of(context).size.width / 2 +
                      2 * kTextTabBarHeight) *
                  min(heightFactor + 0.12, 1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text('CONTATTA GLI SVILUPPATORI:',
                        style: Theme.of(context).textTheme.bodyText1),
                  ),
                  RichText(
                      textAlign: TextAlign.end,
                      text: TextSpan(
                          recognizer: _supportTap,
                          text: 'messeapp@messedaglia.edu.it',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              decoration: TextDecoration.underline)))
                ],
              ),
            ),
            Positioned(
              height: kTextTabBarHeight,
              left: 15 -
                  interpolate(MediaQuery.of(context).size.width, 0.0,
                      max(0, min(1, heightFactor * 10 - 9))),
              right: 15 +
                  interpolate(MediaQuery.of(context).size.width, 0.0,
                      max(0, min(1, heightFactor * 10 - 9))),
              top: (MediaQuery.of(context).size.width / 2 +
                      3 * kTextTabBarHeight) *
                  heightFactor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text('BUGs REPORT:',
                        style: Theme.of(context).textTheme.bodyText1),
                  ),
                  RichText(
                      textAlign: TextAlign.end,
                      text: TextSpan(
                          recognizer: _bugsTap,
                          text: 'github.com/.../issues',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              decoration: TextDecoration.underline)))
                ],
              ),
            )
          ],
        ),
      );

  @override
  double maxExtent(BuildContext context) =>
      MediaQuery.of(context).size.width / 2 + 4 * kTextTabBarHeight;

  @override
  double minExtent(BuildContext context) => 20 + kToolbarHeight;
}
