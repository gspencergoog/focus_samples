// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This example demonstrates moving the focus to the next field when enter is
// pressed.

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
  static const String title = 'Focus Next Field Example';

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
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // Unfocus the current focus if the background is tapped on. The
          // focusPrevious argument says to focus the previously focused item in
          // the scope, if any, and to focus the scope itself if not. If set to
          // false (the default), then the root focus node
          // (FocusManager.instance.rootScope) will be focused, causing all
          // other nodes to not be focused.
          FocusManager.instance.primaryFocus.unfocus();
        },
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // We want more than one, to illustrate that focus is only on the
            // tapped one.
            children: List<Widget>.generate(2, (int index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class FocusOnTapColorButton extends StatefulWidget {
  const FocusOnTapColorButton({this.child, Key key}) : super(key: key);

  final Widget child;

  @override
  _FocusOnTapColorButtonState createState() => _FocusOnTapColorButtonState();
}

class _FocusOnTapColorButtonState extends State<FocusOnTapColorButton> {
  Color _currentColor = Colors.grey;

  bool _handleKeypress(FocusNode node, RawKeyEvent event) {
    if (event is! RawKeyDownEvent) {
      return false;
    }
    final Map<LogicalKeyboardKey, Color> colorMap = <LogicalKeyboardKey, Color>{
      LogicalKeyboardKey.keyR: Colors.red,
      LogicalKeyboardKey.keyG: Colors.green,
      LogicalKeyboardKey.keyB: Colors.blue,
    };
    if (colorMap.containsKey(event.logicalKey)) {
      setState(() {
        _currentColor = colorMap[event.logicalKey];
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKey: _handleKeypress,
      child: Builder(builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Focus.of(context).requestFocus();
          },
          child: Container(color: _currentColor, child: widget.child),
        );
      }),
    );
  }
}
