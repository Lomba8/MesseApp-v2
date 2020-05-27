import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_svg/flutter_svg.dart';

class AppBarNico extends StatelessWidget {
  AppBarNico({
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: BoxConstraints.expand(),
      child: FittedBox(
        fit: BoxFit.cover,
        child: SvgPicture.string(
          _shapeSVG_c82cee0a85cc437897dbb7bed47dd1f5,
          allowDrawingOutsideViewBox: true,
        ),
      ),
    );
  }
}

const String _shapeSVG_c82cee0a85cc437897dbb7bed47dd1f5 =
    '<svg viewBox="0.0 -0.3 375.1 105.6" ><defs><linearGradient id="gradient" x1="0.159715" y1="0.824357" x2="0.959947" y2="0.856618"><stop offset="0.0" stop-color="#ffad9bf3"  /><stop offset="1.0" stop-color="#ff3a3e8a"  /></linearGradient></defs><path transform="translate(0.0, 24.63)" d="M 6.069061279296875 47.75959014892578 C 6.069061279296875 47.75959014892578 -16.37060546875 84.86728668212891 29.4190673828125 79.46502685546875 C 73.7066650390625 72.86186218261719 77.60885620117188 43.46135330200195 148.0353698730469 67.08859252929688 C 200.8386688232422 81.51866149902344 289.4948425292969 69.39418029785156 301.0584411621094 69.57289123535156 C 373.74609375 70.63003540039062 375.149658203125 85.23235321044922 375.0836791992188 73.81002807617188 C 375.0177001953125 62.38769912719727 374.2116088867188 -0.9310411214828491 374.2116088867188 -0.9310411214828491 L 0 -0.9310411214828491 L 6.069061279296875 47.75959014892578 Z" fill="url(#gradient)" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /><defs><linearGradient id="gradient" x1="0.060529" y1="0.86198" x2="0.824425" y2="0.90245"><stop offset="0.0" stop-color="#ff77a4ba"  /><stop offset="0.513166" stop-color="#ff459cc7"  /><stop offset="0.761446" stop-color="#ff7893a0"  /><stop offset="1.0" stop-color="#ff468bb0"  /></linearGradient></defs><path transform="translate(0.0, 1.33)" d="M 0 64.48622131347656 C 0 64.48622131347656 13.76609802246094 102.7937545776367 66.03733825683594 96.16573333740234 C 104.2473068237305 91.32068634033203 174.7583312988281 67.60422515869141 215.0037994384766 74.22942352294922 C 229.572265625 76.62769317626953 281.97216796875 95.30409240722656 344.0193786621094 96.16573333740234 C 412.7832641601562 95.76804351806641 341.0708618164062 32.80735778808594 374.6106872558594 -1.330057382583618 L 0 -1.330057382583618 L 0 64.48622131347656 Z" fill="url(#gradient)" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /><defs><linearGradient id="gradient" x1="0.138654" y1="-0.11368" x2="1.0" y2="0.665029"><stop offset="0.0" stop-color="#ff5a5fb5"  /><stop offset="1.0" stop-color="#ff2e3376"  /></linearGradient></defs><path transform="translate(0.0, -0.33)" d="M 0 105.6300506591797 C 0 105.6300506591797 33.58352279663086 40.12538146972656 138.519775390625 62.19433975219727 C 243.4560394287109 84.26329803466797 224.0031280517578 88.52592468261719 284.1128234863281 89.39317321777344 C 344.2225036621094 90.26042175292969 375 71.52347564697266 375 71.52347564697266 L 375 0 L 0 0 L 0 105.6300506591797 Z" fill="url(#gradient)" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
