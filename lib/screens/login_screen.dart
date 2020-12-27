import 'dart:convert';
import 'dart:io';

import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/preferences/globals.dart';
import 'package:Messedaglia/utils/orariUtils.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:video_player/video_player.dart';
import 'package:circular_splash_transition/circular_splash_transition.dart';

import '../registro/registro.dart';
import 'menu_screen.dart';
import 'package:Messedaglia/main.dart' as main;
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  static final String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  FocusNode _firstInputFocusNode;
  FocusNode _secondInputFocusNode;

  String _username, _password;
  bool splash = true;
  bool _loading = false;

  VideoPlayerController _controller;
  final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();

  CircularSplashController _splash_controller = CircularSplashController(
    color:
        Theme.of(main.mainContext).primaryColor, //optional, default is White.
    duration: Duration(milliseconds: 300), //optional.
  );

  @override
  void initState() {
    super.initState();
    main.route = 'login_screen';

    _controller = VideoPlayerController.asset('videos/loading.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        if (mounted) setState(() {});
      });
    _controller.addListener(() {
      if ((_controller.value.position?.inMicroseconds ?? 0) /
              (_controller.value.duration?.inMicroseconds ?? 1) >=
          1) {
        // _splash_controller.pushReplacementNamed(context, Menu.id);
        Navigator.of(this.context).pushReplacementNamed(Menu.id);
      }
    });
    _controller.setVolume(0.0);

    if (main.add) {
      splash = false;
    } else if (main.session != null) {
      print('main.session!=null');
      if (main.connection_main != ConnectivityResult.none) {
        print('connectivity Online');
        main.session.login().then((ok) async {
          print('login');
          if (ok == '') {
            await downloadOrari();

            downloadAll();
          } else {
            print('splash = false');
            if (mounted) setState(() => splash = false);
          }
        });
      }
    } else
      splash = false;
    // downloadAll();
    _firstInputFocusNode = new FocusNode();
    _secondInputFocusNode = new FocusNode();
  }

  @override
  void dispose() {
    _firstInputFocusNode?.dispose();
    _secondInputFocusNode?.dispose();
    _controller.dispose();
    main.route = '';
    _splash_controller.dispose();
    if (main.add == true) main.add = false;
    super.dispose();
  }

// Navigator.of(this.context).pushReplacementNamed(Menu.id);
  void downloadAll() => main.session.downloadAll((v) {}, downloaders: [
        () async {
          dynamic r;
          r = await http.get('https://app.messe.dev/tutor');
          await main.prefs.setString('tutor', '');
          await main.prefs.setString('tutor', r.body);
        }
      ]);

  void _submit(BuildContext context) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (mounted)
      setState(() {
        _loading = true;
      });

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      RegistroApi account = RegistroApi(uname: _username, pword: _password);
      var req = await account.login(check: true);
      if (req == '') {
        _btnController.success();
        main.session = account;
        await main.session.load();
        if (main.prefs.getString('avatar') != null) {
          main.avatarList = jsonDecode(main.prefs.getString('avatar'));
          main.avatar = jsonDecode(main.prefs.getString('avatar'))
                  .where((e) => e['id'] == main.session.usrId.toString())
                  .isNotEmpty
              ? base64Decode(jsonDecode(main.prefs.getString('avatar'))
                  .where((e) => e['id'] == main.session.usrId.toString())
                  .first['base64'])
              : null;
        } else {
          main.avatar = null;
        }
        if (mounted)
          setState(() {
            splash = true;
          });
        await downloadOrari();
        downloadAll();
      } else {
        _formKey.currentState.reset();
        _btnController.reset();

        if (Platform.isAndroid)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 3),
            content: Text(req +
                '\n' +
                (req != 'Service Unavailable'
                    ? 'Reinserire le credenziali'
                    : 'Riprova piu tardi')),
          ));
        else
          Flushbar(
            padding: EdgeInsets.all(20),
            borderRadius: 20,
            backgroundGradient: LinearGradient(
              colors: [Globals.bluScolorito, Theme.of(context).accentColor],
              stops: [0.3, 1],
            ),
            boxShadows: [
              BoxShadow(
                color: Colors.black45,
                offset: Offset(3, 3),
                blurRadius: 6,
              ),
            ],
            duration: Duration(seconds: 3),
            isDismissible: true,
            icon: Icon(
              Icons.error_outline,
              size: 35,
              color: Theme.of(context).backgroundColor,
            ),
            shouldIconPulse: true,
            animationDuration: Duration(seconds: 1),
            // All of the previous Flushbars could be dismissed by swiping down
            // now we want to swipe to the sides
            dismissDirection: FlushbarDismissDirection.HORIZONTAL,
            // The default curve is Curves.easeOut
            forwardAnimationCurve: Curves.fastOutSlowIn,
            title: req,
            message: req != 'Service Unavailable'
                ? 'Reinserire le credenziali'
                : 'Riprova piu tardi',
          ).show(context);
      }
    }
    if (mounted)
      setState(() {
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData media = MediaQuery.of(context);
    String _image = 'images/logomesse.svg';

    String _loader = (Theme.of(context).brightness == Brightness.dark)
        ? 'images/loading_dark.gif'
        : 'images/loading_light.gif';

    if (splash) {
      if (!_controller.value.isPlaying) _controller.play();

      return CircularSplash(
        controller: _splash_controller,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: _controller.value.initialized
              ? Center(
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.width * 0.7,
                      child: VideoPlayer(_controller)),
                )
              : Container(),
        ),
      );
    }

    return CircularSplash(
      controller: _splash_controller,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Builder(
          builder: (context) => GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            onVerticalDragCancel: () => FocusScope.of(context).unfocus(),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 100.0,
                      height: 100.0,
                      child: !_loading
                          ? SvgPicture.asset(_image,
                              color: !_loading
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent)
                          : Offstage(),
                      decoration: _loading
                          ? BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: AssetImage(
                                    _loader), // link loader https://icons8.com/preloaders/
                              ),
                            )
                          : BoxDecoration(),
                    ),
                    SizedBox(
                      height: media.size.height / 40,
                    ),
                    Text(
                      'Messe App',
                      style: TextStyle(
                        color: (Theme.of(context).brightness == Brightness.dark)
                            ? Globals.bluScolorito
                            : Globals.violaScolorito,
                        fontSize: 20.0,
                        fontFamily: 'CoreSansRounded',
                      ),
                    ),
                    SizedBox(height: media.size.height / 15),
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30.0, vertical: 10.0),
                            child: TextFormField(
                              autofillHints: ['email'],
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  labelText: 'Codice Utente o Email'),
                              focusNode: _firstInputFocusNode,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              validator: (input) {
                                if (input.trim().length < 9 &&
                                    !input.contains('@')) {
                                  setState(() {
                                    _btnController.reset();
                                  });
                                  return "L'username deve essere lungo 9 caratteri";
                                } else if (input.trim()[0].toUpperCase() !=
                                        'G' &&
                                    input.trim()[0].toUpperCase() != 'S' &&
                                    !input.contains('@')) {
                                  setState(() {
                                    _btnController.reset();
                                  });
                                  return 'Sono accettati solo gli account studente (S) e genitore (G)';
                                } else
                                  return null;
                              },
                              onChanged: (input) => _username = input.trim(),
                              onFieldSubmitted: (v) => FocusScope.of(context)
                                  .requestFocus(_secondInputFocusNode),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30.0, vertical: 10.0),
                            child: TextFormField(
                              autofillHints: ['password'],
                              focusNode: _secondInputFocusNode,
                              decoration:
                                  InputDecoration(labelText: 'Password'),
                              textInputAction: TextInputAction.send,
                              autocorrect: false,
                              validator: (input) {
                                if (input.trim().length == 0) {
                                  _btnController.reset();

                                  return 'Inserire una password valida';
                                } else
                                  return null;
                              },
                              onChanged: (input) => _password = input.trim(),
                              onFieldSubmitted: (str) {
                                _btnController.success();
                                _submit(context);
                              },
                              obscureText: true,
                            ),
                          ),
                          SizedBox(
                            height: media.size.height / 15,
                          ),
                          RoundedLoadingButton(
                            controller: _btnController,
                            animateOnTap: true,
                            onPressed: () => _submit(context),
                            color: Theme.of(context).primaryColor,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 80.0, vertical: 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                width: 90.0,
                                child: Text(
                                  'Login',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          main.add
                              ? RoundedLoadingButton(
                                  animateOnTap: false,
                                  onPressed: () => Phoenix.rebirth(context),
                                  color: Colors.red[400],
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 80.0, vertical: 10.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      width: 90.0,
                                      child: Text(
                                        'Annulla',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
                                      ),
                                    ),
                                  ),
                                )
                              : Offstage(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
