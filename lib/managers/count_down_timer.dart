import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
typedef CountdownTimerWidgetBuilder = Widget Function(
    BuildContext context, CurrentRemainingTime? time);

class CountdownTimer extends StatefulWidget {
  ///Widget displayed after the countdown
  final Widget endWidget;
  ///Used to customize the countdown style widget
  final CountdownTimerWidgetBuilder? widgetBuilder;
  ///Countdown controller, can end the countdown event early
  final CountdownTimerController? controller;
  ///Countdown text style
  final TextStyle? textStyle;
  ///Event called after the countdown ends
  final VoidCallback? onEnd;
  ///The end time of the countdown.
  final int? endTime;

  const CountdownTimer({
    super.key,
    this.endWidget = const Center(
      child: Text('The current time has expired'),
    ),
    this.widgetBuilder,
    this.controller,
    this.textStyle,
    this.endTime,
    this.onEnd,
  })  : assert(endTime != null || controller != null);

  @override
  _CountDownState createState() => _CountDownState();
}

class _CountDownState extends State<CountdownTimer> {
  late CountdownTimerController controller;

  CurrentRemainingTime? get currentRemainingTime =>
      controller.currentRemainingTime;

  Widget get endWidget => widget.endWidget;

  CountdownTimerWidgetBuilder get widgetBuilder =>
      widget.widgetBuilder ?? builderCountdownTimer;

  TextStyle? get textStyle => widget.textStyle;

  @override
  void initState() {
    super.initState();
    initController();
  }

  ///Generate countdown controller.
  initController() {
    controller = widget.controller ??
        CountdownTimerController(endTime: widget.endTime!, onEnd: widget.onEnd);
    if (controller.isRunning == false) {
      controller.start();
    }
    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endTime != widget.endTime || widget.controller != oldWidget.controller) {
      controller.dispose();
      initController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widgetBuilder(context, currentRemainingTime);
  }

  Widget builderCountdownTimer(
      BuildContext context, CurrentRemainingTime? time) {
    if (time == null) {
      return endWidget;
    }
    String value = '';
    if (time.days != null) {
      var days = _getNumberAddZero(time.days!);
      value = '$value$days days ';
    }
    var hours = _getNumberAddZero(time.hours ?? 0);
    value = '$value$hours : ';
    var min = _getNumberAddZero(time.min ?? 0);
    value = '$value$min : ';
    var sec = _getNumberAddZero(time.sec ?? 0);
    value = '$value$sec';
    return Text(
      value,
      style: textStyle,
    );
  }

  /// 1 -> 01
  String _getNumberAddZero(int number) {
    if (number < 10) {
      return "0$number";
    }
    return number.toString();
  }
}

class CurrentRemainingTime {
  final int? days;
  final int? hours;
  final int? min;
  final int? sec;
  final Animation<double>? milliseconds;

  CurrentRemainingTime({this.days, this.hours, this.min, this.sec, this.milliseconds});

  @override
  String toString() {
    return 'CurrentRemainingTime{days: $days, hours: $hours, min: $min, sec: $sec, milliseconds: ${milliseconds?.value}';
  }
}
class CountdownTimerController extends ChangeNotifier {
  CountdownTimerController(
      {required int endTime, this.onEnd, TickerProvider? vsync})
      : _endTime = endTime {
    if(vsync != null) {
      _animationController = AnimationController(vsync: vsync, duration: Duration(seconds: 1));
    }
  }

  ///Event called after the countdown ends
  final VoidCallback? onEnd;

  ///The end time of the countdown.
  int _endTime;

  ///Is the countdown running.
  bool _isRunning = false;

  ///Countdown remaining time.
  CurrentRemainingTime? _currentRemainingTime;

  ///Countdown timer.
  Timer? _countdownTimer;

  ///Intervals.
  Duration intervals = const Duration(seconds: 1);

  ///Seconds in a day
  final int _daySecond = 60 * 60 * 24;

  ///Seconds in an hour
  final int _hourSecond = 60 * 60;

  ///Seconds in a minute
  final int _minuteSecond = 60;

  bool get isRunning => _isRunning;

  set endTime(int endTime) => _endTime = endTime;

  ///Get the current remaining time
  CurrentRemainingTime? get currentRemainingTime => _currentRemainingTime;

  AnimationController? _animationController;

  ///Start countdown
  start() {
    disposeTimer();
    _isRunning = true;
    _countdownPeriodicEvent();
    if (_isRunning) {
      _countdownTimer = Timer.periodic(intervals, (timer) {
        _countdownPeriodicEvent();
      });
    }
  }

  ///Check if the countdown is over and issue a notification.
  _countdownPeriodicEvent() {
    _currentRemainingTime = _calculateCurrentRemainingTime();
    _animationController?.reverse(from: 1);
    notifyListeners();
    if (_currentRemainingTime == null) {
      onEnd?.call();
      disposeTimer();
    }
  }

  ///Calculate current remaining time.
  CurrentRemainingTime? _calculateCurrentRemainingTime() {
    int remainingTimeStamp =
    ((_endTime - DateTime.now().millisecondsSinceEpoch) / 1000).floor();
    if (remainingTimeStamp <= 0) {
      return null;
    }
    int? days, hours, min, sec;

    ///Calculate the number of days remaining.
    if (remainingTimeStamp >= _daySecond) {
      days = (remainingTimeStamp / _daySecond).floor();
      remainingTimeStamp -= days * _daySecond;
    }

    ///Calculate remaining hours.
    if (remainingTimeStamp >= _hourSecond) {
      hours = (remainingTimeStamp / _hourSecond).floor();
      remainingTimeStamp -= hours * _hourSecond;
    } else if (days != null) {
      hours = 0;
    }

    ///Calculate remaining minutes.
    if (remainingTimeStamp >= _minuteSecond) {
      min = (remainingTimeStamp / _minuteSecond).floor();
      remainingTimeStamp -= min * _minuteSecond;
    } else if (hours != null) {
      min = 0;
    }

    ///Calculate remaining second.
    sec = remainingTimeStamp.toInt();
    return CurrentRemainingTime(days: days, hours: hours, min: min, sec: sec, milliseconds: _animationController?.view);
  }

  disposeTimer() {
    _isRunning = false;
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  void dispose() {
    disposeTimer();
    _animationController?.dispose();
    super.dispose();
  }
}