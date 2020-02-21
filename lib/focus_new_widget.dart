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

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
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

  void _addChild() {
    // Calling requestFocus here creates a deferred request for focus, since the
    // node is not yet part of the focus tree.
    childFocusNodes
        .add(FocusNode(debugLabel: 'Child ${children.length}')..requestFocus());

    children.add(Padding(
      padding: const EdgeInsets.all(2.0),
      child: ActionChip(
        focusNode: childFocusNodes.last,
        label: Text('CHILD ${children.length}'),
        onPressed: () {},
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
