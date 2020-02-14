// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This example demonstrates being able to focus an item on a tap, and also
// unfocusing when tapping on a background.

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
  static const String title = 'Focus with GlobalKey Example';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<GlobalKey> buttonKeys;
  static const int buttonCount = 2;

  @override
  void initState() {
    super.initState();
    buttonKeys = List<GlobalKey>.generate(buttonCount, (int index) => GlobalKey(debugLabel: 'Button $index'));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: null,
      builder: (context, snapshot) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // Unfocus the primary focus if the background is tapped on.
            FocusManager.instance.primaryFocus.unfocus();
          },
          child: Center(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // We want more than one, to illustrate that focus is only on the
                  // tapped one.
                  children: List<Widget>.generate(buttonCount, (int index) {
                    return FlatButton(
                      focusColor: Colors.red,
                      onPressed: () {},
                      child: Text(
                        'Button $index',
                        textAlign: TextAlign.center,
                        key: buttonKeys[index],
                      ),
                    );
                  }),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // We want more than one, to illustrate that focus is only on the
                  // tapped one.
                  children: List<Widget>.generate(buttonCount, (int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlatButton(
                        child: Text(
                          'Focus Button $index',
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () {
                          Focus.of(buttonKeys[index].currentContext).requestFocus();
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
