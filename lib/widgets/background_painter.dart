import 'package:Messedaglia/preferences/globals.dart';
import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  final ThemeData _theme;
  final Paint p = Paint();
  final Path path = Path();
  final bool back;
  final bool expansion;
  BackgroundPainter(this._theme, {this.back = false, this.expansion = false});

  @override
  void paint(Canvas canvas, Size size) {
    // double k = size.width / 100;

    // path.reset();
    // path.lineTo(0, size.height - 16);
    // path.quadraticBezierTo(
    //     k * 10, size.height - k * 5, k * 21, size.height - k * 3);
    // path.quadraticBezierTo(
    //     k * 36, size.height + k * 0.6, k * 47, size.height - k * 3);
    // path.quadraticBezierTo(
    //     k * 56, size.height - k * 6, k * 63, size.height - k * 12);
    // path.quadraticBezierTo(
    //     k * 81, size.height - k * 27, k * 100, size.height - k * 0.7);
    // path.lineTo(size.width, 0);
    // path.close();
    // p.color = _theme.primaryColor;
    // canvas.drawPath(path, p);

    // path.reset();
    // path.lineTo(0, size.height - 1.5);
    // path.quadraticBezierTo(
    //     k * 19, size.height - k * 23, k * 31, size.height - k * 8);
    // path.quadraticBezierTo(
    //     k * 39, size.height + k * 1, k * 52, size.height - k * 11);
    // path.quadraticBezierTo(
    //     k * 84, size.height - k * 45, k * 100, size.height - k * 8);
    // path.lineTo(size.width, 0);
    // path.close();
    // p.color = _theme.accentColor;
    // canvas.drawPath(path, p);

/* cruva in alto a sinistra

    path.reset();
    path.lineTo(0, size.height * 0.5);
    path.quadraticBezierTo(
        0, size.height * 0.75, size.width * 0.2, size.height * 0.75);
    path.lineTo(size.width, size.height * 0.75);
    path.lineTo(size.width, 0);
    path.close();
    */

    /* cruva in basso a sinistra e in alto a destra
    path.reset();
    path.lineTo(0, size.height * 0.95);
    path.quadraticBezierTo(
        0, size.height * 0.75, size.width * 0.11, size.height * 0.75);
    path.lineTo(size.width * 0.89, size.height * 0.75);
    path.quadraticBezierTo(
        size.width, size.height * 0.75, size.width, size.height * 0.55);
    path.lineTo(size.width, 0);
    path.close();
*/

    // // cruva in alto a sinistra e in alto a destra
    // path.reset();
    // path.moveTo(0, -100);
    // if (back) {
    //   path.lineTo(0, size.height * 0.75);
    //   path.lineTo(size.width * 0.89, size.height * 0.75);
    // } else {
    //   path.lineTo(0, size.height * 0.45);
    //   path.quadraticBezierTo(
    //       0, size.height * 0.75, size.width * 0.11, size.height * 0.75);

    //   path.lineTo(size.width * 0.89, size.height * 0.75);
    // }
    // path.quadraticBezierTo(
    //     size.width, size.height * 0.75, size.width, size.height * 0.45);
    // path.lineTo(size.width, -100);
    // path.close();

    path.reset();
    path.moveTo(0, -100);
    if (back) {
      path.lineTo(0, size.height * 0.75);
      path.lineTo(size.width * 0.89, size.height * 0.75);
    } else {
      path.lineTo(0, size.height * 0.45);
      path.quadraticBezierTo(
        0,
        expansion ? size.height * 0.99 : size.height * 0.75,
        size.width * 0.11,
        expansion ? size.height * 0.99 : size.height * 0.75,
      );

      path.lineTo(
        size.width * 0.89,
        expansion ? size.height * 0.99 : size.height * 0.75,
      );
    }
    path.quadraticBezierTo(
      size.width,
      expansion ? size.height * 0.99 : size.height * 0.75,
      size.width,
      size.height * 0.45,
    );
    path.lineTo(size.width, -100);
    path.close();

    // p.color = _theme.brightness == Brightness.light
    //     ? Color(0xFFBDBDBD)
    //     : Colors.grey[800];
    p.color = Globals.darkTheme.accentColor;
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
