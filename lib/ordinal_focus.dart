// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This example demonstrates being able to set the focus order based on an
// ordinal value, allowing an explicit focus order.

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
  WidgetsApp.debugAllowBannerOverride = false;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const String title = 'Ordered Focus Example';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      // Make the focus highlight a little darker than usual to make it more
      // obvious.
      theme: ThemeData(focusColor: Colors.black38),
      home: OrderedTraversalPage(title: title),
    );
  }
}

class DemoButton extends StatefulWidget {
  const DemoButton({this.name, this.canRequestFocus = true, this.autofocus = false, this.order});

  final String name;
  final bool canRequestFocus;
  final bool autofocus;
  final double order;

  @override
  _DemoButtonState createState() => _DemoButtonState();
}

class _DemoButtonState extends State<DemoButton> {
  FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode(
      debugLabel: widget.name,
      canRequestFocus: widget.canRequestFocus,
    );
  }

  @override
  void dispose() {
    focusNode?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DemoButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    focusNode.canRequestFocus = widget.canRequestFocus;
  }

  void _handleOnPressed() {
    focusNode.requestFocus();
    print('Button ${widget.name} pressed.');
    debugDumpFocusTree();
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalOrder(
      order: NumericFocusOrder(widget.order),
      child: FlatButton(
        focusNode: focusNode,
        autofocus: widget.autofocus,
        focusColor: Colors.red,
        hoverColor: Colors.blue,
        onPressed: () => _handleOnPressed(),
        child: Text(widget.name),
      ),
    );
  }
}

class OrderedTraversalPage extends StatelessWidget {
  OrderedTraversalPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return DefaultFocusTraversal(
      policy: OrderedFocusTraversalPolicy(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              DemoButton(
                name: 'Six',
                order: 6,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              DemoButton(name: 'Five', order: 5),
              DemoButton(
                name: 'Four',
                canRequestFocus: false,
                order: 4,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              DemoButton(name: 'Three', order: 3),
              DemoButton(name: 'Two', order: 2),
              DemoButton(name: 'One', order: 1, autofocus: true),
            ],
          ),
        ],
      ),
    );
  }
}
