import 'dart:convert';
import 'package:applicazione_prova/server/server.dart';
import 'package:applicazione_prova/preferences/globals.dart';
import 'package:applicazione_prova/screens/home_screen.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();

    _firstInputFocusNode = new FocusNode();
    _secondInputFocusNode = new FocusNode();
  }

  @override
  void dispose() {
    _firstInputFocusNode.dispose();
    _secondInputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData media = MediaQuery.of(context);

    String _image, _username, _password;

    (MediaQuery.platformBrightnessOf(context).toString() == 'Brightness.dark')
        ? _image = 'images/logomesse_scuro.png'
        : _image = 'images/logomesse_chiaro.png';

    String _usernameMsg = 'L\'username deve essere lungo 9 caratteri';
    String _passwordMsg = 'La passoword deve essere lunga 8 caratteri';

    void _submit() async {
      SystemChannels.textInput.invokeMethod('TextInput.hide');

      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();
        var _server = Server(_username, _password);

        if (await _server.login()) {
          Navigator.pushReplacementNamed(context, Menu.id);
        } else {
          _formKey.currentState.reset();
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
          )..show(context);
        }
      }
    }

    void _submitString(String text) async {
      SystemChannels.textInput.invokeMethod('TextInput.hide');

      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();
        var _server = Server(_username, _password);

        if (await _server.login()) {
          _formKey.currentState.save();

          if (await _server.login()) {
            Navigator.pushReplacementNamed(context, Menu.id);
          } else {
            _formKey.currentState.reset();
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
            )..show(context);
          }
        }
      }
    }

    return Container(
      color: Theme.of(context).backgroundColor,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            onVerticalDragCancel: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Container(
                height: media.size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: media.size.height / 10,
                    ),
                    Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: ExactAssetImage(_image),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: media.size.height / 40,
                    ),
                    Text(
                      'Messe App',
                      style: TextStyle(
                        color: (MediaQuery.platformBrightnessOf(context)
                                    .toString() ==
                                'Brightness.dark')
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
                              decoration: InputDecoration(
                                labelText: 'Nome utente',
                                labelStyle: TextStyle(
                                  letterSpacing: 1.0,
                                ),
                              ),
                              focusNode: _firstInputFocusNode,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              validator: (input) =>
                                  input.length < 9 ? _usernameMsg : null,
                              onSaved: (input) => _username = input,
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
                              decoration:
                                  InputDecoration(labelText: 'Password'),
                              textInputAction: TextInputAction.send,
                              autocorrect: false,
                              validator: (input) =>
                                  input.length != 8 ? _passwordMsg : null,
                              onSaved: (input) => _password = input,
                              onFieldSubmitted: _submitString,
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
                            child: Text(
                              'Login',
                              style: Theme.of(context).textTheme.body1,
                            ),
                          )
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
