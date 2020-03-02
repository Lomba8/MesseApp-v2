import 'package:Messedaglia/registro/registro.dart';
import 'package:Messedaglia/preferences/globals.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../registro/registro.dart';
import 'menu_screen.dart';

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

  double _progress = 0;
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('videos/loading.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });

    SharedPreferences.getInstance().then((prefs) {
      _username = prefs.getString('username');
      _password = prefs.getString('password');
      if (_username == null || _password == null)
        setState(() => splash = false);
      else {
        RegistroApi.login(_username, _password, false).then((ok) {
          if (ok)
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
    });

    _firstInputFocusNode = new FocusNode();
    _secondInputFocusNode = new FocusNode();
  }

  @override
  void dispose() {
    _firstInputFocusNode?.dispose();
    _secondInputFocusNode?.dispose();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData media = MediaQuery.of(context);
    String _image, _loader;
    GlobalKey _scaffoldKey = GlobalKey();

    (Theme.of(context).brightness == Brightness.dark)
        ? _image = 'images/logomesse_scuro.png'
        : _image = 'images/logomesse_chiaro.png';

    (Theme.of(context).brightness == Brightness.dark)
        ? _loader = 'images/loading_dark.gif'
        : _loader = 'images/loading_light.gif';

    if (splash) {
      _controller.play();
      return Scaffold(
          backgroundColor: Colors.black,
          body: _controller.value.initialized
              ? Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.width * 0.7,
                        child: VideoPlayer(_controller),
                      ),
                    ],
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

    String _usernameMsg = 'L\'username deve essere lungo 9 caratteri';
    String _passwordMsg = 'La password deve essere lunga 8 caratteri';

    void _submit() async {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      setState(() {
        _loading = true;
      });

      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();

        if (await RegistroApi.login(_username, _password, true)) {
          setState(() {
            splash = true;
          });
          RegistroApi.downloadAll((double progress) => setState(() {
                _progress = progress;
                if (progress == 1)
                  Navigator.pushReplacementNamed(context, Menu.id);
              }));
        } else {
          _formKey.currentState.reset();

          /*if (Platform.isAndroid)
            (_scaffoldKey.currentState as ScaffoldState).showSnackBar(SnackBar(
              duration: Duration(seconds: 3),
              content: Text(
                  "Username o password errate! Reinserire le credenziali."),
            ));
          else*/
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
            title: 'Username o password errati',
            message: 'Reinserire le credenziali',
          ).show(context);
        }
      }
      setState(() {
        _loading = false;
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        onVerticalDragCancel: () {
          FocusScope.of(context).unfocus();
        },
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
                          decoration: InputDecoration(labelText: 'Nome utente'),
                          focusNode: _firstInputFocusNode,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          validator: (input) =>
                              input.length < 9 ? _usernameMsg : null,
                          onChanged: (input) {
                            print(input);
                            _username = input.trim();
                          },
                          onFieldSubmitted: (v) {
                            FocusScope.of(context)
                                .requestFocus(_secondInputFocusNode);
                          },
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
                          validator: (input) =>
                              input.length == 0 ? _passwordMsg : null,
                          onChanged: (input) {
                            print(input);
                            _password = input.trim();
                          },
                          onFieldSubmitted: (str) => _submit(),
                          obscureText: true,
                        ),
                      ),
                      SizedBox(
                        height: media.size.height / 15,
                      ),
                      FlatButton(
                          onPressed: _submit,
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
    );
  }
}
