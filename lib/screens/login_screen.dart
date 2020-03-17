import 'dart:io';

import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/preferences/globals.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../registro/registro.dart';
import 'menu_screen.dart';
import 'package:Messedaglia/main.dart' as main;

class LoginScreen extends StatefulWidget {
  static final String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  FocusNode _firstInputFocusNode;
  FocusNode _secondInputFocusNode;

  String _username, _password;
  bool splash = true;
  bool _loading = false;
  bool finished = false;

  double _progress = 0;
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    main.route = 'login_screen';

    _controller = VideoPlayerController.asset('videos/loading.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    _controller.addListener(() {
      if (_controller.value.isPlaying != true) {
        finished = true;
      }
    });

    if (main.connection_main != ConnectivityResult.none) {
      RegistroApi.login().then((ok) {
        if (ok == '')
          RegistroApi.downloadAll((double progress) {
            setState(() {
              _progress = progress;
              if (progress == 1)
                Navigator.pushReplacementNamed(context, Menu.id);
            });
          });
        else
          setState(() => splash = false);
      });
    }
    _firstInputFocusNode = new FocusNode();
    _secondInputFocusNode = new FocusNode();
    finished = false;
  }

  @override
  void dispose() {
    _firstInputFocusNode?.dispose();
    _secondInputFocusNode?.dispose();
    _controller.dispose();
    main.route = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData media = MediaQuery.of(context);
    String _image = (Theme.of(context).brightness == Brightness.dark)
        ? 'images/logomesse_scuro.png'
        : 'images/logomesse_chiaro.png';

    String _loader = (Theme.of(context).brightness == Brightness.dark)
        ? 'images/loading_dark.gif'
        : 'images/loading_light.gif';

    if (splash) {
      _controller.play();

      return Scaffold(
          backgroundColor: Colors.black,
          body: _controller.value.initialized
              ? Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.width * 0.7,
                    child: !finished
                        ? VideoPlayer(_controller)
                        : Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fitWidth,
                                image: ExactAssetImage(
                                    'images/gif-2.gif'), //FIXME con materiali di nico ma l'idea c'é
                              ),
                            ),
                          ),
                  ),
                )
              : Container(),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.05),
              child: SizedBox(
                height: 2.0,
                child: LinearProgressIndicator(
                  value: _progress,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Theme.of(context).accentColor),
                ),
              ),
            ),
          ));
    }

    void _submit(BuildContext context) async {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      setState(() {
        _loading = true;
      });

      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();
        var req = await RegistroApi.login(
            username: _username, password: _password, check: true);
        if (req == '') {
          setState(() {
            splash = true;
          });
          RegistroApi.downloadAll((double progress) => setState(() {
                _progress = progress;
                if (progress == 1)
                  Navigator.of(this.context).pushReplacementNamed(Menu.id);
              }));
        } else {
          _formKey.currentState.reset();

          if (Platform.isAndroid)
            Scaffold.of(context).showSnackBar(SnackBar(
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
      setState(() {
        _loading = false;
      });
    }

    return Scaffold(
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
                    decoration: BoxDecoration(
                      color: !_loading
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: !_loading
                            ? ExactAssetImage(_image)
                            : AssetImage(
                                _loader), // link loader https://icons8.com/preloaders/
                      ),
                    ),
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
                            decoration:
                                InputDecoration(labelText: 'Nome utente'),
                            focusNode: _firstInputFocusNode,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            validator: (input) => input.length < 9
                                ? "L'username deve essere lungo 9 caratteri" //FIXME ci si puo loggare anche con la email
                                : input[0].toUpperCase() != 'G' &&
                                        input[0].toUpperCase() != 'S'
                                    ? 'Solo accettati solo gli account studente (S) e genitore (G)'
                                    : null,
                            onChanged: (input) => _username = input.trim(),
                            onFieldSubmitted: (v) => FocusScope.of(context)
                                .requestFocus(_secondInputFocusNode),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 10.0),
                          child: TextFormField(
                            focusNode: _secondInputFocusNode,
                            decoration: InputDecoration(labelText: 'Password'),
                            textInputAction: TextInputAction.send,
                            autocorrect: false,
                            validator: (input) => input.length == 0
                                ? 'La password deve essere lunga 8 caratteri'
                                : null, // FIXME: la password è modificabile
                            onChanged: (input) => _password = input.trim(),
                            onFieldSubmitted: (str) => _submit(context),
                            obscureText: true,
                          ),
                        ),
                        SizedBox(
                          height: media.size.height / 15,
                        ),
                        FlatButton(
                            onPressed: () => _submit(context),
                            color: Theme.of(context).primaryColor,
                            splashColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 120.0, vertical: 16.0),
                            child: Container(
                              width: 90.0,
                              child: Text(
                                'Login',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                            ))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
