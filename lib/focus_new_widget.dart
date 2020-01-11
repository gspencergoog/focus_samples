// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This example demonstrates being able to focus a newly created item.

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
  static const String title = 'Focus New Widget Example';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChildCreator(title: title),
    );
  }
}

class ChildCreator extends StatefulWidget {
  ChildCreator({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ChildCreatorState createState() => _ChildCreatorState();
}

class _ChildCreatorState extends State<ChildCreator> {
  int focusedChild = 0;
  List<Widget> children = <Widget>[];
  List<FocusNode> childFocusNodes = <FocusNode>[];

  @override
  void initState() {
    super.initState();
    // Add the first child.
    _addChild();
  }

  @override
  void dispose() {
    super.dispose();
    childFocusNodes.forEach((FocusNode node) => node.dispose());
  }

  Widget _createChild(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RaisedButton(
        focusNode: childFocusNodes[index],
        focusColor: Colors.redAccent,
        child: Text(
          'CHILD $index',
        ),
        onPressed: () {},
      ),
    );
  }

  void _addChild() {

    // Calling requestFocus here creates a deferred request for focus, since the
    // node is not yet part of the focus tree.
    childFocusNodes.add(FocusNode(debugLabel: 'Child ${children.length}')..requestFocus());

    children.add(_createChild(children.length));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Wrap(
          children: children,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            focusedChild = children.length;
            _addChild();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
