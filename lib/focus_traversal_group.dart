// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This example demonstrates being able to set the focus order based on an
// ordinal value, allowing an explicit focus order.

import 'dart:async';
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

class OrderedButton<T> extends StatefulWidget {
  const OrderedButton({this.name, this.canRequestFocus = true, this.autofocus = false, this.order});

  final String name;
  final bool canRequestFocus;
  final bool autofocus;
  final T order;

  @override
  _OrderedButtonState createState() => _OrderedButtonState();
}

class _OrderedButtonState<T> extends State<OrderedButton<T>> {
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
  void didUpdateWidget(OrderedButton oldWidget) {
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
    print('Adding widget with order ${widget.order}');
    return FocusTraversalOrder(
      order: widget.order is double ? NumericFocusOrder(widget.order as double) : LexicalFocusOrder(widget.order.toString()),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: OutlineButton(
          focusNode: focusNode,
          autofocus: widget.autofocus,
          focusColor: Colors.red,
          hoverColor: Colors.blue,
          onPressed: () => _handleOnPressed(),
          child: Text(widget.name),
        ),
      ),
    );
  }
}

class OrderedTraversalPage extends StatelessWidget {
  OrderedTraversalPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // A group that is ordered with a numerical order, from left to right.
            FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(3, (int index) {
                  return OrderedButton<double>(
                    name: 'double: $index',
                    order: index.toDouble(),
                  );
                }),
              ),
            ),
            // A group that is ordered with a lexical order, from right to left.
            FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(3, (int index) {
                  // Order as "C" "B", "A".
                  String order = String.fromCharCode('A'.codeUnitAt(0) + (2 - index));
                  return OrderedButton<String>(
                    name: 'String: $order',
                    order: order,
                  );
                }),
              ),
            ),
            // A group that orders in widget order, regardless of what the order is set to.
            FocusTraversalGroup(
              policy: WidgetOrderTraversalPolicy(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(3, (int index) {
                  return OrderedButton<double>(
                    name: 'double: ${2 - index}',
                    order: (2 - index).toDouble(),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
