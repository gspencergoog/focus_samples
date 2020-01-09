// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This example shows how to take a non-focusable element and wrap it in a
// FocusableActionDetector to handle things like activation, hover highlights,
// and focus.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  static const String title = 'FocusableActionDetector Example';

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
      body: MyList(),
    );
  }
}

class MyList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => FocusableActionText('Item $index', autofocus: index == 0),
      itemCount: 50,
    );
  }
}

class ChangeColorAction extends ActivateAction {
  ChangeColorAction(this.color, {@required this.onColorChanged}) : assert(color != null);

  final Color color;
  final ValueChanged<Color> onColorChanged;

  @override
  void invoke(FocusNode node, Intent intent) => onColorChanged?.call(color);
}

class FocusableActionText extends StatefulWidget {
  const FocusableActionText(this.data, {Key key, this.autofocus}) : super(key: key);

  final String data;
  final bool autofocus;

  @override
  _FocusableActionTextState createState() => _FocusableActionTextState();
}

class _FocusableActionTextState extends State<FocusableActionText> {
  Map<LocalKey, ActionFactory> _actionMap;
  Color _focusColor = Colors.black12;
  static final List<Color> colors = <Color>[
    Colors.red.withOpacity(0.5),
    Colors.green.withOpacity(0.5),
    Colors.blue.withOpacity(0.5),
  ];
  int _colorIndex = 0;

  @override
  void initState() {
    super.initState();
    _actionMap = <LocalKey, ActionFactory>{
      ActivateAction.key: _createAction,
    };
  }

  void _updateColor(Color color) {
    setState(() {
      _focusColor = color;
      _colorIndex = (_colorIndex + 1) % colors.length;
    });
  }

  Action _createAction() {
    return ChangeColorAction(
      colors[_colorIndex],
      onColorChanged: _updateColor,
    );
  }

  bool _focused = false;
  void _handleFocusHighlightChanged(bool focused) {
    if (focused != _focused) {
      setState(() {
        _focused = focused;
      });
    }
  }

  bool _hovering = false;
  void _handleHoverChanged(bool hovering) {
    if (hovering != _hovering) {
      setState(() {
        _hovering = hovering;
      });
    }
  }

  Color _getColor() {
    if (_hovering) {
      return _focusColor.withOpacity(0.25);
    }
    if (_focused) {
      return _focusColor;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      actions: _actionMap,
      autofocus: widget.autofocus,
      onShowFocusHighlight: _handleFocusHighlightChanged,
      onShowHoverHighlight: _handleHoverChanged,
      child: Builder(builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Focus.of(context).requestFocus();
          },
          child: Container(
            padding: EdgeInsets.all(8.0),
            color: _getColor(),
            child: Text(widget.data),
          ),
        );
      }),
    );
  }
}
