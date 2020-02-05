// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This example shows how to take a non-focusable element and wrap it so that it
// is focusable, and shows a focus highlight.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Sets a platform override for desktop to avoid exceptions. See
// https://flutter.dev/desktop#target-platform-override for more info.
// TODO(gspencergoog): Remove once TargetPlatform includes all desktop platforms.
void _enablePlatformOverrideForDesktop() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

void main() {
  _enablePlatformOverrideForDesktop();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const String title = 'Actions Example';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: NudgeExample(),
    );
  }
}

class NudgeExample extends StatefulWidget {
  @override
  _NudgeExampleState createState() => _NudgeExampleState();
}

class _NudgeExampleState extends State<NudgeExample> {
  bool enabled = true;
  NudgeAction action = NudgeAction();

  static double nudgeSize = 5.0;
  static double jumpSize = 20.0;

  static final Map<LogicalKeySet, Intent> _shortcuts = <LogicalKeySet, Intent>{
    LogicalKeySet(LogicalKeyboardKey.arrowUp): NudgeIntent(direction: AxisDirection.up, amount: nudgeSize),
    LogicalKeySet(LogicalKeyboardKey.arrowDown): NudgeIntent(direction: AxisDirection.down, amount: nudgeSize),
    LogicalKeySet(LogicalKeyboardKey.arrowLeft): NudgeIntent(direction: AxisDirection.left, amount: nudgeSize),
    LogicalKeySet(LogicalKeyboardKey.arrowRight): NudgeIntent(direction: AxisDirection.right, amount: nudgeSize),
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowUp): NudgeIntent(direction: AxisDirection.up, amount: jumpSize),
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowDown): NudgeIntent(direction: AxisDirection.down, amount: jumpSize),
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowLeft): NudgeIntent(direction: AxisDirection.left, amount: jumpSize),
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowRight): NudgeIntent(direction: AxisDirection.right, amount: jumpSize),
  };

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: _shortcuts,
      child: Actions(
        actions: <Type, Action>{ NudgeIntent: action },
        child: Stack(
          children: <Widget>[
            NudgeCanvas(),
            Positioned(
              right: 0,
              top: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text('Nudge Enabled'),
                  Switch(
                    value: enabled,
                    onChanged: (bool value) {
                      setState(() {
                        enabled = value;
                        action.enabled = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A helper class that defines actions that can register listeners that receive
/// notification of a value change when the action was invoked.
/// This could be added as an actual Flutter class if it proves useful.
abstract class ChangedValueAction<I extends Intent, T> extends Action<I> {
  ObserverList<ValueChanged<T>> _listeners = ObserverList<ValueChanged<T>>();

  void addValueListener(ValueChanged<T> listener) => _listeners.add(listener);
  void removeValueListener(ValueChanged<T> listener) => _listeners.remove(listener);

  @protected
  void notifyValueListeners(T value) {
    if (_listeners.isEmpty) {
      return;
    }
    final List<ValueChanged<T>> localListeners = List<ValueChanged<T>>.from(_listeners);
    for (final ValueChanged<T> listener in localListeners) {
      if (_listeners.contains(listener)) {
        listener(value);
      }
    }
  }

  T computeValue(I intent);

  @override
  @nonVirtual
  T invoke(I intent) {
    T result = computeValue(intent);
    notifyValueListeners(result);
    return result;
  }
}

class NudgeIntent extends Intent {
  NudgeIntent({this.direction, this.amount});

  final AxisDirection direction;
  final double amount;
}

class NudgeAction extends ChangedValueAction<NudgeIntent, Offset> {
  @override
  bool get enabled {
    return _enabled;
  }
  bool _enabled = true;
  set enabled(bool value) {
    if (_enabled == value) {
      return;
    }
    _enabled = value;
    notifyActionListeners();
  }

  @override
  Offset computeValue(NudgeIntent intent) {
    Offset delta;
    switch (intent.direction) {
      case AxisDirection.up:
        delta = Offset(0.0, -intent.amount);
        break;
      case AxisDirection.right:
        delta = Offset(intent.amount, 0.0);
        break;
      case AxisDirection.down:
        delta = Offset(0.0, intent.amount);
        break;
      case AxisDirection.left:
        delta = Offset(-intent.amount, 0.0);
        break;
    }
    return delta;
  }
}

class NudgeCanvas extends StatefulWidget {
  const NudgeCanvas({Key key, this.enabled}) : super(key: key);

  final bool enabled;

  @override
  _NudgeCanvasState createState() => _NudgeCanvasState();
}

class _NudgeCanvasState extends State<NudgeCanvas> {
  Rect rect;
  MaterialColor color;
  NudgeAction action;

  @override
  void initState() {
    super.initState();
    rect = Rect.fromLTWH(0.0, 0.0, 100.0, 100.0);
  }

  @override
  void dispose() {
    super.dispose();
    action?.removeValueListener(_handleRectChanged);
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    NudgeAction newAction = Actions.find<NudgeIntent>(context);
    if (newAction != action) {
      action?.removeValueListener(_handleRectChanged);
      action = newAction;
      action?.addValueListener(_handleRectChanged);
    }
  }

  void _handleEnabledChange(Action<Intent> action) {
    setState(() {
      color = action?.enabled == true ? Colors.blue : Colors.red;
    });
  }

  void _handleRectChanged(Offset delta) {
    setState(() {
      rect = rect.shift(delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    action ??= (Actions.find<NudgeIntent>(context) as NudgeAction)..addValueListener(_handleRectChanged);

    return Focus(
      autofocus: true,
      child: Builder(builder: (BuildContext context) {
        return ActionListener(
          action: Actions.find<NudgeIntent>(context),
          listener: _handleEnabledChange,
          child: Stack(
            children: <Widget>[
              Positioned.fromRect(child: FlutterLogo(colors: color), rect: rect),
            ],
          ),
        );
      }),
    );
  }
}
