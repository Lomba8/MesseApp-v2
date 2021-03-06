import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_parsing/path_parsing.dart';

final String _rawMapData = '''{
  "aule": {
    "item": "un'aula",
    "mask": {
      "PALESTRA 1": [
        "PALESTRA 1"
      ],
      "PALESTRA 2": [
        "PALESTRA 2"
      ],
      "PALESTRINA": [
        "PALESTRINA"
      ],
      "LABORATORIO BIOLOGIA": [
        "LABORATORIO BIOLOGIA"
      ],
      "LABORATORIO ROBOTICA": [
        "LABORATORIO ROBOTICA"
      ],
      "AULA MAGNA": [
        "AULA MAGNA"
      ],
      "LABORATORIO CHIMICA 3": [
        "LABORATORIO CHIMICA 3"
      ],
      "LABORATORIO FISICA": [
        "LABORATORIO FISICA"
      ],
      "AULA 3 BIS": [
        "AULA 3 BIS"
      ],
      "AULA 1": [
        "AULA 1"
      ],
      "AULA 2": [
        "AULA 2"
      ],
      "AULA 3": [
        "AULA 3"
      ],
      "AULA 4": [
        "AULA 4"
      ],
      "AULA 5": [
        "AULA 5"
      ],
      "AULA 6": [
        "AULA 6"
      ],
      "AULA 7": [
        "AULA 7"
      ],
      "AULA 8": [
        "AULA 8"
      ],
      "AULA 9": [
        "AULA 9"
      ],
      "AULA 10": [
        "AULA 10"
      ],
      "AULA INSEGNANTI": [
        "AULA INSEGNANTI"
      ],
      "AULA 13 BIS": [
        "AULA 13 BIS"
      ],
      "AULA 11": [
        "AULA 11"
      ],
      "AULA 12": [
        "AULA 12"
      ],
      "AULA 13": [
        "AULA 13"
      ],
      "AULA 14": [
        "AULA 14"
      ],
      "AULA 15": [
        "AULA 15"
      ],
      "SEGRETERIA AMMINISTRATIVA": [
        "SEGRETERIA AMMINISTRATIVA"
      ],
      "PRESIDENZA": [
        "PRESIDENZA"
      ],
      "AULA 16": [
        "AULA 16"
      ],
      "AULA 17": [
        "AULA 17"
      ],
      "AULA 18": [
        "AULA 18"
      ],
      "AULA 19": [
        "AULA 19"
      ],
      "AULA 20": [
        "AULA 20"
      ],
      "AULA 20 BIS": [
        "AULA 20 BIS"
      ],
      "LABORATORIO CHIMICA": [
        "LABORATORIO CHIMICA"
      ],
      "AULA 21": [
        "AULA 21"
      ],
      "AULA 22": [
        "AULA 22"
      ],
      "AULA 23": [
        "AULA 23"
      ],
      "AULA 24": [
        "AULA 24"
      ],
      "AULA 25": [
        "AULA 25"
      ],
      "LABORATORIO LINGUE": [
        "LABORATORIO LINGUE"
      ],
      "LABORATORIO INFO": [
        "LABORATORIO INFO"
      ],
      "AULA 26": [
        "AULA 26"
      ],
      "AULA 27": [
        "AULA 27"
      ],
      "AULA 28": [
        "AULA 28"
      ],
      "AULA 29": [
        "AULA 29"
      ],
      "AULA 30": [
        "AULA 30"
      ],
      "AULA 30 BIS": [
        "AULA 30 BIS"
      ],
      "BIBLIOTECA": [
        "BIBLIOTECA"
      ],
      "AULA 31": [
        "AULA 31"
      ],
      "AULA 32": [
        "AULA 32"
      ],
      "AULA 33": [
        "AULA 33"
      ],
      "AULA 34": [
        "AULA 34"
      ],
      "AULA 35": [
        "AULA 35"
      ],
      "AULA 36": [
        "AULA 36"
      ]
    },
    "decorations": [],
    "classes": []
  },
  "classi": {
    "item": "una classe",
    "mask": {
      "2A": [
        "AULA 1"
      ],
      "2B": [
        "AULA 10"
      ],
      "2C": [
        "AULA 4"
      ],
      "2E": [
        "AULA 6"
      ],
      "2F": [
        "AULA 3 BIS"
      ],
      "2G": [
        "AULA 8"
      ],
      "2I": [
        "AULA 3"
      ],
      "2L": [
        "AULA 2"
      ],
      "2M": [
        "AULA 9"
      ],
      "2N": [
        "AULA 7"
      ],
      "3A": [
        "AULA 15"
      ],
      "3B": [
        "AULA 20 BIS"
      ],
      "3C": [
        "AULA 14"
      ],
      "3D": [
        "AULA 13 BIS"
      ],
      "3E": [
        "AULA 18"
      ],
      "3F": [
        "AULA 17"
      ],
      "3G": [
        "AULA 11"
      ],
      "3H": [
        "AULA 5"
      ],
      "3I": [
        "AULA 20"
      ],
      "3L": [
        "AULA 19"
      ],
      "4A": [
        "AULA 28"
      ],
      "4B": [
        "AULA 27"
      ],
      "4C": [
        "AULA 26"
      ],
      "4D": [
        "AULA 12"
      ],
      "4E": [
        "AULA 16"
      ],
      "4F": [
        "AULA 30 BIS"
      ],
      "4G": [
        "AULA 30"
      ],
      "4H": [
        "AULA 13"
      ],
      "5A": [
        "AULA 33"
      ],
      "5B": [
        "AULA 23"
      ],
      "5C": [
        "AULA 32"
      ],
      "5D": [
        "AULA 25"
      ],
      "5E": [
        "AULA 29"
      ],
      "5F": [
        "AULA 36"
      ],
      "5G": [
        "AULA 21"
      ],
      "5H": [
        "AULA 35"
      ],
      "5I": [
        "AULA 31"
      ],
      "5L": [
        "AULA 34"
      ],
      "5M": [
        "AULA 24"
      ],
      "5N": [
        "AULA 22"
      ]
    },
    "decorations": [],
    "classes": []
  },
  "autogestione": {
    "item": "un'attività",
    "mask": {
      "JUST DANCE": [
        "AULA MAGNA"
      ],
      "SIMPOSIO": [
        "AULA 11",
        "AULA 13",
        "AULA 18",
        "AULA 20"
      ],
      "QUIZ": [
        "AULA 22",
        "AULA 24"
      ],
      "VIDEOGAMES": [
        "AULA 29"
      ],
      "BUBBLE FOOTBALL": [
        "PALESTRA 1",
        "PALESTRA 2"
      ],
      "CINEFORUM": [
        "AULA 32",
        "AULA 33",
        "AULA 34",
        "AULA 35"
      ],
      "BADMINGTON": [
        "BADMINGTON 1",
        "BADMINGTON 2",
        "BADMINGTON 3"
      ]
    },
    "decorations": [
      {
        "builder": "M24.3,40.02L11.73,27.48M7.05,22.77 7.05,15.18 11.73,10.5L32.79,31.5L24.3,40.02M44.64,34.59L40.23,39.0L60.87,59.64L56.64,63.87L36.0,43.23L15.36,63.87L11.13,59.64L40.41,30.36C38.28,25.77 39.78,19.32 44.55,14.55C50.28,8.79 58.5,7.71 62.88,12.09C67.29,16.5 66.21,24.72 60.45,30.45C55.68,35.22 49.23,36.72 44.64,34.59M0.0,0.0M24.3,40.02L11.73,27.48C7.05,22.77 7.05,15.18 11.73,10.5L32.79,31.5L24.3,40.02M44.64,34.59L40.23,39.0L60.87,59.64L56.64,63.87L36.0,43.23L15.36,63.87L11.13,59.64L40.41,30.36C38.28,25.77 39.78,19.32 44.55,14.55C50.28,8.79 58.5,7.71 62.88,12.09C67.29,16.5 66.21,24.72 60.45,30.45C55.68,35.22 49.23,36.72 44.64,34.59Z",
        "offsetX": 800,
        "offsetY": -200,
        "fillColor": 4279060385,
        "strokeColor": 4279060385,
        "selectable": false
      }
    ],
    "classes": [
      {
        "BADMINGTON 1": {
          "builder": "M0,0v60h100v-60z",
          "stroke": "M0,0v60h100v-60zM50,0v60",
          "offsetX": 550,
          "offsetY": -175,
          "fillColor": 0,
          "strokeColor": -1
        },
        "BADMINGTON 2": {
          "builder": "M0,0v60h100v-60z",
          "stroke": "M0,0v60h100v-60zM50,0v60",
          "offsetX": 400,
          "offsetY": -175,
          "fillColor": 0,
          "strokeColor": -1
        },
        "BADMINGTON 3": {
          "builder": "M0,0v60h100v-60z",
          "stroke": "M0,0v60h100v-60zM50,0v60",
          "offsetX": 250,
          "offsetY": -175,
          "fillColor": 0,
          "strokeColor": -1
        }
      },
      {
        "BADMINGTON 1": {
          "builder": "M0,0v60h100v-60z",
          "stroke": "M0,0v60h100v-60zM50,0v60",
          "offsetX": 550,
          "offsetY": -175,
          "fillColor": 0,
          "strokeColor": -1
        },
        "BADMINGTON 2": {
          "builder": "M0,0v60h100v-60z",
          "stroke": "M0,0v60h100v-60zM50,0v60",
          "offsetX": 400,
          "offsetY": -175,
          "fillColor": 0,
          "strokeColor": -1
        },
        "BADMINGTON 3": {
          "builder": "M0,0v60h100v-60z",
          "stroke": "M0,0v60h100v-60zM50,0v60",
          "offsetX": 250,
          "offsetY": -175,
          "fillColor": 0,
          "strokeColor": -1
        }
      },
      {
        "BADMINGTON 1": {
          "builder": "M0,0v60h100v-60z",
          "stroke": "M0,0v60h100v-60zM50,0v60",
          "offsetX": 550,
          "offsetY": -175,
          "fillColor": 0,
          "strokeColor": -1
        },
        "BADMINGTON 2": {
          "builder": "M0,0v60h100v-60z",
          "stroke": "M0,0v60h100v-60zM50,0v60",
          "offsetX": 400,
          "offsetY": -175,
          "fillColor": 0,
          "strokeColor": -1
        },
        "BADMINGTON 3": {
          "builder": "M0,0v60h100v-60z",
          "stroke": "M0,0v60h100v-60zM50,0v60",
          "offsetX": 250,
          "offsetY": -175,
          "fillColor": 0,
          "strokeColor": -1
        }
      },
      {
        "BADMINGTON 1": {
          "builder": "M0,0v60h100v-60z",
          "stroke": "M0,0v60h100v-60zM50,0v60",
          "offsetX": 550,
          "offsetY": -175,
          "fillColor": 0,
          "strokeColor": -1
        },
        "BADMINGTON 2": {
          "builder": "M0,0v60h100v-60z",
          "stroke": "M0,0v60h100v-60zM50,0v60",
          "offsetX": 400,
          "offsetY": -175,
          "fillColor": 0,
          "strokeColor": -1
        },
        "BADMINGTON 3": {
          "builder": "M0,0v60h100v-60z",
          "stroke": "M0,0v60h100v-60zM50,0v60",
          "offsetX": 250,
          "offsetY": -175,
          "fillColor": 0,
          "strokeColor": -1
        }
      },
      {
        "BADMINGTON 1": {
          "builder": "M0,0v60h100v-60z",
          "stroke": "M0,0v60h100v-60zM50,0v60",
          "offsetX": 550,
          "offsetY": -175,
          "fillColor": 0,
          "strokeColor": -1
        },
        "BADMINGTON 2": {
          "builder": "M0,0v60h100v-60z",
          "stroke": "M0,0v60h100v-60zM50,0v60",
          "offsetX": 400,
          "offsetY": -175,
          "fillColor": 0,
          "strokeColor": -1
        },
        "BADMINGTON 3": {
          "builder": "M0,0v60h100v-60z",
          "stroke": "M0,0v60h100v-60zM50,0v60",
          "offsetX": 250,
          "offsetY": -175,
          "fillColor": 0,
          "strokeColor": -1
        }
      },
      {
        "BADMINGTON 1": {
          "builder": "M0,0v60h100v-60z",
          "stroke": "M0,0v60h100v-60zM50,0v60",
          "offsetX": 550,
          "offsetY": -175,
          "fillColor": 0,
          "strokeColor": -1
        },
        "BADMINGTON 2": {
          "builder": "M0,0v60h100v-60z",
          "stroke": "M0,0v60h100v-60zM50,0v60",
          "offsetX": 400,
          "offsetY": -175,
          "fillColor": 0,
          "strokeColor": -1
        },
        "BADMINGTON 3": {
          "builder": "M0,0v60h100v-60z",
          "stroke": "M0,0v60h100v-60zM50,0v60",
          "offsetX": 250,
          "offsetY": -175,
          "fillColor": 0,
          "strokeColor": -1
        }
      }
    ]
  }
}'''; // TODO: CAMBIARE SOLO da: dopo l'uguale al punto e virgola //compreso
// FIXME: comprimere i floor uguali

final Map<String, dynamic> mapData = jsonDecode(_rawMapData)
  ..forEach((key, data) {
    data['decorations'] = data['decorations']
        .map<PathData>((pathData) => PathData.parse(pathData))
        .toList();
    data['classes'] = data['classes']
        .map((floor) => floor.map<String, PathData>(
            (String key, data) => MapEntry(key, PathData.parse(data))))
        .toList();
  });

int getFloor(String className, String mask) {
  for (int i = 0; i < floors.length; i++)
    if (floors[i].classes.containsKey(className) &&
        floors[i].classes[className].selectable) return i - 2;
  for (int i = 0; i < mapData[mask]['classes'].length; i++)
    if (mapData[mask]['classes'][i].containsKey(className) &&
        mapData[mask]['classes'][i][className].selectable) return i - 2;
  return null;
}

final List<PathData> decorations = [
  PathData(
      builder: PathBuilder('M0,-182h1000v382h-2000'),
      offset: Offset(0, 0),
      fillColor: Colors.lightGreen.withAlpha(100),
      strokeColor: Colors.transparent),
  PathData(
      builder: PathBuilder('v-435h-1000V-182H-292v182',
          close: true, startFromOrigin: true),
      stroke: PathBuilder(
          'M0,-395l-126.6,32.5M-1000,-182H-292V-320l126.6,-32.5',
          close: false),
      offset: Offset(1000, 0),
      fillColor: Colors.grey),
];

// COMMON PATH DATA:
final PathData palestra1 = PathData(
  builder: pathBuilders['gym'],
  offset: const Offset(163, 0),
);
final PathData class_1 =
    PathData(builder: pathBuilders['class1'], offset: const Offset(156, 0));
final PathData class_2 = PathData(
    builder: pathBuilders['class1'],
    offset: const Offset(326, 0),
    symmetric: true);
final PathData class_3 =
    PathData(builder: pathBuilders['class2'], offset: const Offset(103, 121));
final PathData class_3BIS =
    PathData(builder: pathBuilders['class3'], offset: const Offset(0, 169));
final PathData class_4 =
    PathData(builder: pathBuilders['class0'], offset: const Offset(204, 121));
final PathData class_5 = PathData(
    builder: pathBuilders['class2'],
    offset: const Offset(379, 121),
    symmetric: true);
final PathData classLab =
    PathData(builder: pathBuilders['class4'], offset: const Offset(103, 0));
final PathData lab =
    PathData(builder: pathBuilders['lab'], offset: const Offset(379, 169));
final PathData lab2 =
    PathData(builder: pathBuilders['lab2'], offset: const Offset(593, 169));
final PathData class31 =
    PathData(builder: pathBuilders['class6'], offset: const Offset(103, 20));
final PathData class32 = PathData(
    builder: pathBuilders['class6'],
    offset: const Offset(259, 20),
    symmetric: true);
final PathData class33 =
    PathData(builder: pathBuilders['class5'], offset: const Offset(259, 20));

final PathData bagnoM = PathData(
    builder: pathBuilders['bagno'],
    offset: const Offset(0, 0),
    fillColor: const Color(0xA00000AA),
    selectable: false);
final PathData bagnoF = PathData(
    builder: pathBuilders['bagno'],
    offset: const Offset(0, 0),
    fillColor: const Color(0xA0E427B3),
    selectable: false);

final List<Floor> floors = [
  // -2
  Floor({
    'scuola': scuole['sede1'],
    'succursale':
        scuole['succursale1'].withColor(fillColor: Colors.transparent),
    'PALESTRA 1': palestra1,
    'PALESTRA 2': palestra1.getSymmetric()
  }),
  // -1
  Floor({
    'scuola': scuole['sede1'],
    'succursale': scuole['succursale1'],
    'PALESTRINA': class_3BIS,
    'LABORATORIO BIOLOGIA': classLab,
    'LABORATORIO ROBOTICA': PathData(
        builder: pathBuilders['class4'],
        stroke: pathBuilders['class4v2'],
        offset: Offset(319, 0)),
    'AULA MAGNA':
        PathData(builder: pathBuilders['aulamgn'], offset: Offset(379, 169)),
    'LABORATORIO CHIMICA 3': classLab.getSymmetric(),
    'LABORATORIO FISICA': class_3BIS.getSymmetric(),
    'palestra1': PathData(
        builder: pathBuilders['gym2'],
        offset: Offset(163, 0),
        fillColor: Color(0x50000000),
        selectable: false),
    'palestra2': PathData(
        builder: pathBuilders['gym'],
        offset: Offset(593, 0),
        fillColor: Color(0x50000000),
        selectable: false)
  }),
  // 0
  Floor({
    'scuola': scuole['sede1'],
    'succursale': scuole['succursale2'].withColor(fillColor: Colors.white30),
    'AULA 3 BIS': class_3BIS,
    'AULA 1': class_1,
    'AULA 2': class_2,
    'AULA 3': class_3,
    'AULA 4': class_4,
    'AULA 5': class_5,
    'AULA 6': class_2.getSymmetric(),
    'AULA 7': class_1.getSymmetric(),
    'AULA 8': class_5.getSymmetric(),
    'AULA 9': class_4.getSymmetric(),
    'AULA 10': class_3.getSymmetric(),
    'AULA INSEGNANTI': class_3BIS.getSymmetric(),
    'bagno1': bagnoM,
    'bagno2': bagnoF.getSymmetric()
  }),
  // 1
  Floor({
    'scuola': scuole['sede2'],
    'succursale': scuole['succursale2'].withColor(fillColor: Colors.white30),
    'AULA 13 BIS': class_3BIS,
    'AULA 11': class_1,
    'AULA 12': class_2,
    'AULA 13': class_3,
    'AULA 14': class_4,
    'AULA 15': class_5,
    'SEGRETERIA AMMINISTRATIVA': lab,
    'PRESIDENZA': lab2,
    'AULA 16': class_2.getSymmetric(),
    'AULA 17': class_1.getSymmetric(),
    'AULA 18': class_5.getSymmetric(),
    'AULA 19': class_4.getSymmetric(),
    'AULA 20': class_3.getSymmetric(),
    'AULA 20 BIS': class_3BIS.getSymmetric(),
    'bagno1': bagnoF,
    'bagno2': bagnoM.getSymmetric()
  }),
  // 2
  Floor({
    'scuole': scuole['sede2'],
    'succursale': scuole['succursale2'].withColor(fillColor: Colors.white30),
    'LABORATORIO CHIMICA': class_3BIS,
    'AULA 21': class_1,
    'AULA 22': class_2,
    'AULA 23': class_3,
    'AULA 24': class_4,
    'AULA 25': class_5,
    'LABORATORIO LINGUE': lab,
    'LABORATORIO INFO': lab2,
    'AULA 26': class_2.getSymmetric(),
    'AULA 27': class_1.getSymmetric(),
    'AULA 28': class_5.getSymmetric(),
    'AULA 29': class_4.getSymmetric(),
    'AULA 30': class_3.getSymmetric(),
    'AULA 30 BIS': class_3BIS.getSymmetric(),
    'bagno1': bagnoM,
    'bagno2': bagnoF.getSymmetric()
  }),
  // 3
  Floor({
    'scuola': scuole['sede3'], // TODO: fix rientro in alto
    'succursale': scuole['succursale2'].withColor(fillColor: Colors.white30),
    'AULA 31': class31,
    'AULA 32': class32,
    'AULA 33': class33,
    'BIBLIOTECA':
        PathData(builder: pathBuilders['biblio'], offset: Offset(379, 169)),
    'AULA 34': class33.getSymmetric(),
    'AULA 35': class32.getSymmetric(),
    'AULA 36': class31.getSymmetric(),
    'bagno1': bagnoF,
    'bagno2': bagnoM.getSymmetric(),
    'lab chimica': class_3BIS.withColor(
        fillColor: Color(0x50000000), strokeColor: Colors.transparent),
    'aula 30bis': class_3BIS.getSymmetric().withColor(
        fillColor: Color(0x50000000), strokeColor: Colors.transparent)
  })
];

class Floor {
  Map<String, PathData> classes;

  Floor(this.classes) {
    classes['decoration0'] = PathData(
        builder: pathBuilders['stairs'],
        offset: Offset(-7, 46),
        selectable: false,
        fillColor: Colors.transparent);
    classes['decoration1'] = classes['decoration0'].getSymmetric();
    classes['decoration2'] = PathData(
        builder: pathBuilders['stairs2'],
        offset: Offset(379, 0),
        selectable: false,
        symmetric: false,
        fillColor: Colors.transparent);
    classes['decoration3'] = classes['decoration2'].getSymmetric();
  }

  List<String> get classesList {
    List<String> list = [];
    for (String key in classes.keys) if (classes[key].selectable) list.add(key);
    return list;
  }
}

final Map<String, PathData> scuole = {
  'sede1': PathData(
    builder: PathBuilder(
        'v46h-7v50h7v73h103v-48h276v48h214v-48h276v48h103v-73h7v-50h-7v-46'),
    fillColor: Colors.lime[900],
    selectable: false,
  ),
  'sede2': PathData(
    builder: PathBuilder(
        'v46h-7v50h7v73h103v-48h276v48h92v-30h30v30h92v-48h276v48h103v-73h7v-50h-7v-46'),
    fillColor: Colors.lime[900],
    selectable: false,
  ),
  'sede3': PathData(
    builder: PathBuilder(
        'v46h-7v50h7v73h103v-73v25h276v48h214v-48h276v-25v73h103v-73h7v-50h-7v-46h-103v20h-276v-20h-214v20h-276v-20'),
    fillColor: Colors.lime[900],
    selectable: false,
  ),
  'succursale1': PathData(
      builder: PathBuilder('h-513v-228h114v114h285v-114h114', close: true),
      fillColor: Colors.lime[900],
      offset: Offset(986, -475),
      selectable: false),
  'succursale2': PathData(
      builder: PathBuilder('h-513v-228h114v114h285v-114h114', close: true),
      stroke: PathBuilder(
          '''h-513m0,-38h513m0,-38h-513m0,-38h513m0,-38h-114m-285,0h-114m0,-38h114m285,0h114m0,-38h-114m-285,0h-114
    v228m57,0v-228m57,0v228m57,0v-114m57,0v114m57,0v-114m57,0v114m57,0v-228m57,0v228m57,0v-228''',
          close: false),
      fillColor: Colors.lime[900],
      offset: Offset(986, -475),
      selectable: false)
};
final Map<String, PathBuilder> pathBuilders = {
  'tree': PathBuilder(
      'q-10,-14,8,-16q0,-20,16,-16q10,-10,16,4q16,-2,14,12q14,10,0,20q8,16,-8,20q-12,28,-24,4q-20,8,-16,-12q-14,-4,-6,-16'),
  'lab': PathBuilder('M92,-73v73h-92v-73h72', close: false),
  'lab2': PathBuilder('M-72,-73h72v73h-92v-58v28h-30v-43h30', close: false),
  'class0': PathBuilder('M74,-40v40h-74v-50h54v10', close: false),
  'class1': PathBuilder('M0,50h85v-50h-85v30', close: false),
  'class2': PathBuilder('M101,-40v40h-101v-50h81v10', close: false),
  'class3': PathBuilder('M103,-73v73h-103v-73h83', close: false),
  'class4': PathBuilder('M0,26v-26h60v121h-60v-75', close: false),
  'class4v2': PathBuilder('M60,50v-50h-60v121h60v-51', close: false),
  'class5': PathBuilder('M86,0h-86v61h86v-41', close: false),
  'class6': PathBuilder('M78,51v-51h-78v61h58,v-10', close: false),
  'gym': PathBuilder('h216v121h-216'),
  'gym2': PathBuilder('h156v121h-156'),
  'stairs': PathBuilder(
      'M21,0v50m10,0v-50m10,0v50m10,0v-50m10,0v50m21,-25v25h-82v-50h82M21,25h40',
      close: false,
      startFromOrigin: false), // 82* 50
  'stairs2': PathBuilder(
      'M21,0v50m10,0v-50m10,0v50m10,0v-50m10,0v50m21,0h-82v-50h82M21,25h40',
      close: false,
      startFromOrigin: false),
  'biblio': PathBuilder('h214v-98h-214'),
  'bagno': PathBuilder('h103v46h-103'),
  'aulamgn': PathBuilder('''h214v-68h-40l-15,-30h-104l-15,30h-40z
  M51.25,-90.5L76.77,-81.06H137.23L162.75,-90.5
  M47.5,-83L74.73,-72.93H139.27L166.5,-83
  M43.75,-75.5L72.7,-64.79H141.3L170.25,-75.5
  M40,-68L70.66,-56.66H143.34L174,-68

  M32.5,-53L66.59,-40.39H147.41L181.5,-53
  M28.75,-45.5L64.56,-32.36H149.45L185.25,-45.5
  M25,-38L62.52,-24.12H151.48L189,-38
  M21.25,-30.5L60.49,-15.99H153.52L192.75,-30.5''', close: false),
};

class PathData {
  final PathBuilder builder;
  final PathBuilder stroke;
  final Offset offset;
  final bool selectable;
  final bool symmetric;
  final Color fillColor;
  final Color strokeColor;
  PathData(
      {@required this.builder,
      this.stroke,
      this.offset = const Offset(0, 0),
      this.selectable = true,
      this.symmetric = false,
      this.fillColor,
      this.strokeColor});

  Path getFill(double crop, Paint paint,
      {Color color, double translateX = 0, double translateY = 0}) {
    paint
      ..color = color ?? fillColor ?? Colors.lime[800]
      ..style = PaintingStyle.fill;
    return builder.create(
        translation: offset.translate(translateX, translateY),
        cropWidth: crop,
        cropHeight: crop,
        symm: symmetric);
  }

  static PathData parse(Map data) => PathData(
      builder:
          PathBuilder(data['builder'], close: false, startFromOrigin: false),
      stroke: PathBuilder(data['stroke'] ?? data['builder'],
          close: false, startFromOrigin: false),
      offset: Offset(
          data['offsetX'].toDouble() ?? 0.0, data['offsetY'].toDouble() ?? 0.0),
      selectable: data['selectable'] ?? true,
      symmetric: data['symmetric'] ?? false,
      fillColor: Color(data['fillColor'] ?? 0),
      strokeColor: Color(data['strokeColor'] ?? 0));

  Path getStroke(double crop, Paint paint,
      {Color defaultColor = Colors.transparent,
      double translateX = 0,
      double translateY = 0}) {
    paint
      ..color = strokeColor ?? defaultColor ?? Colors.transparent
      ..style = PaintingStyle.stroke;
    return (stroke ?? builder).create(
        translation: offset.translate(translateX, translateY),
        cropWidth: crop,
        cropHeight: crop,
        symm: symmetric);
  }

  PathData getSymmetric() => PathData(
      builder: builder,
      fillColor: fillColor,
      offset: Offset(972 - offset.dx, offset.dy),
      selectable: selectable,
      stroke: stroke,
      strokeColor: strokeColor,
      symmetric: !symmetric);
  PathData withColor({Color fillColor, Color strokeColor}) => PathData(
      builder: builder,
      fillColor: fillColor ?? this.fillColor,
      offset: offset,
      selectable: selectable,
      stroke: stroke,
      strokeColor: strokeColor ?? this.strokeColor,
      symmetric: symmetric);
}

class PathBuilder extends PathProxy {
  String _svg;
  double _width, _height; // crop factor
  Offset _offset;
  int _symm;
  Path _path = Path();

  PathBuilder(String svg, {bool close = true, bool startFromOrigin = true}) {
    _svg = '${startFromOrigin ? 'M0,0' : ''}$svg${close ? 'z' : ''}';
  }

  Path create(
      {Offset translation = const Offset(0, 0),
      double cropWidth = 1.0,
      double cropHeight = 1.0,
      bool symm = false}) {
    _path.reset();
    _width = cropWidth;
    _height = cropHeight;
    _offset = translation;
    _symm = symm ? -1 : 1;
    writeSvgPathDataToPath(_svg, this);
    return _path;
  }

  @override
  String toString() => _svg;

  @override
  void close() {
    _path.close();
  }

  @override
  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    _path.cubicTo(
        (_symm * x1 + _offset.dx) * _width,
        (y1 + _offset.dy) * _height,
        (_symm * x2 + _offset.dx) * _width,
        (y2 + _offset.dy) * _height,
        (_symm * x3 + _offset.dx) * _width,
        (y3 + _offset.dy) * _height);
  }

  @override
  void lineTo(double x, double y) {
    _path.lineTo((_symm * x + _offset.dx) * _width, (y + _offset.dy) * _height);
  }

  @override
  void moveTo(double x, double y) {
    _path.moveTo((_symm * x + _offset.dx) * _width, (y + _offset.dy) * _height);
  }
}
