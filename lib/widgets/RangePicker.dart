//PS: è un copia incolla
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

typedef PickerConfirmCallback = void Function(DateTime start, DateTime end);

enum DateTimeRangePickerMode {
  time,
  date,
  dateAndTime,
}

class DateTimeRangePicker {
  final startText;
  final endText;
  final doneIcon;
  final cancelIcon;
  final DateTimeRangePickerMode mode;

  DateTime initialStartTime;
  DateTime initialEndTime;

  final VoidCallback onCancel;
  final PickerConfirmCallback onConfirm;

  final int interval;

  DateTimeRangePicker(
      {Key key,
      this.onCancel,
      this.onConfirm,
      this.startText = "Start",
      this.endText = "End",
      this.doneIcon = Icons.check,
      this.cancelIcon = Icons.close,
      this.initialStartTime,
      this.initialEndTime,
      this.mode = DateTimeRangePickerMode.dateAndTime,
      this.interval = 15});

  void showPicker(BuildContext context) {
    if (initialStartTime == null) {
      initialStartTime = DateTime.now();
    }

    // Remove minutes and seconds
    initialStartTime = initialStartTime.subtract(Duration(
        minutes: initialStartTime.minute, seconds: initialStartTime.second));

    if (initialEndTime == null) {
      initialEndTime = initialStartTime.add(Duration(
          days: mode == DateTimeRangePickerMode.time ? 0 : 1,
          hours: mode == DateTimeRangePickerMode.time ? 2 : 0));
    }

    initialEndTime = initialEndTime.subtract(Duration(
        minutes: initialEndTime.minute, seconds: initialEndTime.second));

    var pickerMode = CupertinoDatePickerMode.dateAndTime;

    switch (mode) {
      case DateTimeRangePickerMode.date:
        {
          pickerMode = CupertinoDatePickerMode.date;
        }
        break;

      case DateTimeRangePickerMode.time:
        {
          pickerMode = CupertinoDatePickerMode.time;
        }
        break;

      default:
        {
          pickerMode = CupertinoDatePickerMode.dateAndTime;
        }
        break;
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return FractionallySizedBox(
            widthFactor: 0.8,
            heightFactor: 0.5,
            child: PickerWidget([
              Tab(text: startText),
              Tab(text: endText),
            ], initialStartTime, initialEndTime, interval, this.onCancel,
                this.onConfirm, pickerMode, this.doneIcon, this.cancelIcon),
          );
        });
  }
}

class PickerWidget extends StatefulWidget {
  final List<Tab> _tabs;
  final int _interval;
  final VoidCallback _onCancel;
  final PickerConfirmCallback _onConfirm;

  final DateTime _initStart;
  final DateTime _initEnd;
  final CupertinoDatePickerMode _mode;

  final IconData _doneIcon;
  final IconData _cancelIcon;

  PickerWidget(
      this._tabs,
      this._initStart,
      this._initEnd,
      this._interval,
      this._onCancel,
      this._onConfirm,
      this._mode,
      this._doneIcon,
      this._cancelIcon,
      {Key key})
      : super(key: key);

  _PickerWidgetState createState() => _PickerWidgetState();
}

class _PickerWidgetState extends State<PickerWidget>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  DateTime _start;
  DateTime _end;

  @override
  void initState() {
    super.initState();
    _start = widget._initStart;
    _end = widget._initEnd;

    _tabController = TabController(vsync: this, length: widget._tabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Container(
            child: TabBar(
              controller: _tabController,
              tabs: widget._tabs,
              labelColor: Theme.of(context).primaryColor,
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Container(
              height: 250,
              alignment: Alignment.topCenter,
              child: TabBarView(
                controller: _tabController,
                children: widget._tabs.map((Tab tab) {
                  return CupertinoDatePicker(
                    mode: widget._mode,
                    minuteInterval: widget._interval,
                    initialDateTime:
                        tab.text == widget._tabs.first.text ? _start : _end,
                    onDateTimeChanged: (DateTime newDateTime) {
                      if (tab.text == widget._tabs.first.text) {
                        setState(() {
                          _start = newDateTime;
                        });
                      } else {
                        setState(() {
                          _end = newDateTime;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (widget._onCancel != null) {
                        widget._onCancel();
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
                      child: Icon(
                        widget._cancelIcon,
                        color: Colors.redAccent[400],
                        size: 30.0,
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (widget._onConfirm != null) {
                        widget._onConfirm(_start, _end);
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
                      child: Icon(
                        widget._doneIcon,
                        color: Colors.lightGreenAccent[700],
                        size: 30.0,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
