// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
          // Unfocus the current focus if the background is tapped on.
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
                child: FocusOnTapColorButton(
                  child: Container(
                    alignment: Alignment.center,
                    width: 100,
                    height: 100,
                    child: Text(
                      'Tap Me and press R, G, B.',
                      textAlign: TextAlign.center,
                    ),
                  ),
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
