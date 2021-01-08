import 'dart:convert';
import 'dart:math';
import 'package:Messedaglia/main.dart' as main;
import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/utils/db_manager.dart' as dbManager;
import 'package:Messedaglia/widgets/expansion_sliver.dart';
import 'package:account_selector/account.dart';
import 'package:Messedaglia/widgets/account_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:url_launcher/url_launcher.dart';

class Preferences extends StatefulWidget {
  @override
  _PreferencesState createState() => _PreferencesState();
}

_launchURL(String url, BuildContext context) async {
  try {
    if (await canLaunch(Uri.encodeFull(url))) {
      await launch(Uri.encodeFull(url), forceWebView: true);
    } else {
      showSimpleNotification(
        Center(
          child: Text(
            'Impossibile aprire l\'url:\n',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        background: Theme.of(context).accentColor,
        position: NotificationPosition.bottom,
        duration: Duration(seconds: 2),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        slideDismiss: true,
        subtitle: Center(
          child: Text(
            url,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ),
      );
      throw 'Could not launch $url';
    }
  } catch (e, s) {
    print(e);
    print(s);
  }
}

class _PreferencesState extends State<Preferences> {
  bool _darkTheme = main.theme == ThemeMode.dark; //TODO: dynamic theme o senza?

  List<Account> accountList = List<Account>.empty(growable: true);
  List<int> accountIds = List<int>.empty(growable: true);

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
                  applicationName: main.pkgInfo.appName,
                ),
              ),
            ),
            body: _Header(),
            expansion: false,
            back: true,
            preferences: true,
          ),
        ),
        SliverFillRemaining(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CupertinoButton(
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
                          Phoenix.rebirth(context);
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
                ),
              ],
            ),
          ),
        )
      ]));
}

class _Header extends ResizableWidget {
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
                      text: '${main.pkgInfo.appName}  ',
                      style: Theme.of(context).textTheme.bodyText2,
                      children: [
                        TextSpan(
                            text:
                                '${main.pkgInfo.appName} (${main.pkgInfo.buildNumber})',
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
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _launchURL(
                                'https://www.messedaglia.edu.it', context),
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
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _launchURL(
                                'mailto:messeapp@messedaglia.edu.it?subject=FEEDBACK MESSEAPP&body=${main.pkgInfo.appName} (${main.pkgInfo.version} running on ${main.platform} ${main.osVersion})',
                                context),
                          text: '...@messedaglia.edu.it',
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
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _launchURL(
                                'https://github.com/Lomba8/MesseApp-v2/issues',
                                context),
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
