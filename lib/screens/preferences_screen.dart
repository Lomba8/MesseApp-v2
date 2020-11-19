import 'dart:convert';
import 'dart:math';
import 'package:Messedaglia/main.dart' as main;
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/utils/db_manager.dart' as dbManager;
import 'package:Messedaglia/screens/menu_screen.dart' as menu;
import 'package:Messedaglia/widgets/background_painter.dart';
import 'package:Messedaglia/widgets/expansion_sliver.dart';
import 'package:account_selector/account.dart';
import 'package:Messedaglia/widgets/account_selector.dart';
import 'package:android_intent/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cupertino_tabbar/cupertino_tabbar.dart' as CupertinoTabBar;
import 'package:flutter/gestures.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Preferences extends StatefulWidget {
  @override
  _PreferencesState createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  bool _darkTheme = main.theme == ThemeMode.dark;
  int cupertinoTabBarIValue = main.theme == ThemeMode.dark ? 0 : 1;
  int cupertinoTabBarIValueGetter() => cupertinoTabBarIValue;
  List<Account> accountList = List<Account>();
  List<int> accountIds = List<int>();

  @override
  void initState() {
    dbManager.accounts.forEach((account) {
      accountList.add(
        Account(
          title: account.nome,
          accountImageWidget: CircleAvatar(
            backgroundColor: Colors.grey,
            child: Center(
              child: Text(
                account.nome
                    .split(' ')
                    .map((e) => e[0].toString())
                    .join('')
                    .trim(),
              ),
            ),
          ),
        ),
      );
      accountIds.add(account.usrId);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Material(
      color: Theme.of(context).backgroundColor,
      child: CustomScrollView(slivers: <Widget>[
        ExpansionSliver(
          ExpansionSliverDelegate(
            context,
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
                  applicationName: main.appName,
                ),
              ),
            ),
            body: _Header(),
            expansion: true,
            back: true,
          ),
        ),
        SliverFillRemaining(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                    child: CupertinoButton(
                  color: Theme.of(context).accentColor,
                  child: Text(
                    'Accounts',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'CoreSans',
                      fontSize: 20,
                      letterSpacing: 1.2,
                    ),
                  ),
                  onPressed: () {
                    showAccountSelectorSheet(
                      context: context,
                      accountList: accountList,
                      accountIds: accountIds,
                      isSheetDismissible: true,
                      initiallySelectedIndex:
                          accountIds.indexOf(main.session.usrId),
                      hideSheetOnItemTap: true,
                      addAccountTitle: "Add User",
                      showAddAccountOption: true,
                      backgroundColor: Colors.grey[800],
                      arrowColor: Colors.white,
                      unselectedRadioColor: Colors.white,
                      selectedRadioColor: Theme.of(context).primaryColor,
                      unselectedTextColor: Colors.white,
                      selectedTextColor: Theme.of(context).primaryColor,
                      tapCallback: (id) async {
                        //use the index of item selected to do your work over here
                        print('switching to $id');
                        if (id == main.session.usrId)
                          return;
                        else {
                          main.session =
                              dbManager.accounts[accountIds.indexOf(id)];
                          await main.session
                              .load(); //FIXME session.load() is asynchronous and it renders menu_screen.dart bvefore the data is retrieved and managed
                          if (main.prefs.getString('avatar') != null) {
                            main.avatarList =
                                jsonDecode(main.prefs.getString('avatar'));
                            main.avatar = jsonDecode(
                                        main.prefs.getString('avatar'))
                                    .where((e) => e['id'] == id.toString())
                                    .isNotEmpty
                                ? base64Decode(
                                    jsonDecode(main.prefs.getString('avatar'))
                                        .where((e) =>
                                            e['id'] ==
                                            main.session.usrId.toString())
                                        .first['base64'])
                                : null;
                          } else {
                            main.avatar = null;
                          }
                          Phoenix.rebirth(
                              context); //FIXME non riesce a disporre il menu.timer
                        }
                      },
                      addAccountTapCallback: () {
                        // operation to perform when add account is clicked
                        print('adding');
                        main.add = true;
                        Phoenix.rebirth(
                            context); //FIXEM manc il sesison.load() (?)
                      },
                      removeAccountTapCallback: (int id) async {
                        // operation to perform when add account is deleted
                        print('deleting $id');
                        bool reload = id == main.session.usrId;
                        await dbManager.database.rawDelete(
                            'DELETE FROM auth WHERE usrId = ?', [id]);
                        await dbManager.init();
                        main.session = dbManager.accounts?.isNotEmpty ?? false
                            ? dbManager.accounts.first
                            : null;
                        await main.session?.load();
                        if (reload) {
                          dispose();
                          if (main.prefs.getString('avatar') != null) {
                            main.avatarList.removeWhere(
                                (element) => element['id'] == id.toString());
                            main.prefs.setString(
                                'avatar', jsonEncode(main.avatarList));
                          } else {
                            main.avatar = null;
                          }
                          Phoenix.rebirth(context);
                        } else {
                          dbManager.accounts =
                              (await dbManager.database.query('auth'))
                                  .map((raw) => RegistroApi.parse(raw))
                                  .toList();

                          accountIds.clear();
                          accountList.clear();
                          dbManager.accounts.forEach((account) {
                            accountList.add(
                              Account(
                                title: account.nome,
                                accountImageWidget: CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  child: Center(
                                    child: Text(
                                      account.nome
                                          .split(' ')
                                          .map((e) => e[0].toString())
                                          .join('')
                                          .trim(),
                                    ),
                                  ),
                                ),
                              ),
                            );
                            accountIds.add(account.usrId);
                          });

                          Navigator.of(context).pop();
                        }
                      },
                    );
                  },
                )),

                // CupertinoTabBar.CupertinoTabBar(
                //   cupertinoTabBarIValue == 0
                //       ? const Color(0xFF537ec5) // azzurro
                //       : const Color(0xFFffd69f), //arancione

                //   cupertinoTabBarIValue == 0
                //       ? const Color(0xFF293a80) // blu
                //       : const Color(0xFFeb999a), // rosso
                //   [
                //     Icon(
                //       MdiIcons.weatherNight,
                //       size: cupertinoTabBarIValue == 0 ? 20.0 * 1.5 : 20.0,
                //     ),
                //     Icon(
                //       MdiIcons.whiteBalanceSunny,
                //       size: cupertinoTabBarIValue == 1 ? 20.0 * 1.5 : 20.0,
                //     )
                //   ],
                //   cupertinoTabBarIValueGetter,
                //   (int index) {
                //     setState(() {
                //       cupertinoTabBarIValue = index;
                //       setTheme(cupertinoTabBarIValue == 0
                //           ? ThemeMode.dark
                //           : ThemeMode.light);
                //     });
                //   },
                // ),
              ],
            ),
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
                'mailto:messeapp@messedaglia.edu.it?subject=FEEDBACK MESSEAPP&body=${main.appName} (${main.appVersion} running on ${main.platform} ${main.osVersion}')
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
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.all(interpolate(0.0, 20.0, heightFactor)),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: interpolate(
                      Theme.of(context).primaryColor.withOpacity(0),
                      Theme.of(context).primaryColor,
                      heightFactor,
                    ),
                    shape: BoxShape.circle),
                child: Image.asset(
                  'images/logomesse.png',
                  color: interpolate(
                    Colors.white,
                    Colors.black,
                    heightFactor,
                  ),
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
                      text: '${main.appName}  ',
                      style: Theme.of(context).textTheme.bodyText2,
                      children: [
                        TextSpan(
                            text: '(${main.appVersion})',
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
