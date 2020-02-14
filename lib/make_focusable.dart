// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This example shows how to take a non-focusable element and wrap it so that it
// is focusable, and shows a focus highlight.

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
  static const String title = 'Make Focusable Example';

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
      itemBuilder: (context, index) => FocusableText(
        'Item $index',
        autofocus: index == 0,
      ),
      itemCount: 50,
    );
  }
}

class FocusableText extends StatelessWidget {
  const FocusableText(this.data, {Key key, this.autofocus}) : super(key: key);

  /// The string to display as the text for this widget.
  final String data;

  /// Whether or not to focus this widget initially if nothing else is focused.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: autofocus,
      child: Builder(builder: (BuildContext context) {
        // The contents of this Builder are being made focusable. It is inside
        // of a Builder because the building provides the correct context
        // variable for Focus.of() to be able to find the Focus widget that is
        // the Builder's parent. Without the builder, the context variable used
        // would be the one given the FocusableText build function, and that
        // would start looking for a Focus widget ancestor of the FocusableText
        // instead of finding the one inside of its build function.
        return Container(
          padding: EdgeInsets.all(8.0),
          // Change the color based on whether or not this Container has focus.
          color: Focus.of(context).hasPrimaryFocus ? Colors.black12 : null,
          child: Text(data),
        );
      }),
    );
  }
}
