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
      home: MyStatelessWidget(),
    );
  }
}

/// A button wrapper that adds either a numerical or lexical order, depending on
/// the type of T.
class OrderedButton<T> extends StatefulWidget {
  const OrderedButton(
      {this.name,
        this.canRequestFocus = true,
        this.autofocus = false,
        this.order});

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
    FocusOrder order;
    if (widget.order is num) {
      order = NumericFocusOrder((widget.order as num).toDouble());
    } else {
      order = LexicalFocusOrder(widget.order.toString());
    }

    return FocusTraversalOrder(
      order: order,
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

/// This is the stateless widget that the main application instantiates.
class MyStatelessWidget extends StatelessWidget {
  MyStatelessWidget({Key key}) : super(key: key);

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
                  return OrderedButton<num>(
                    name: 'num: $index',
                    // TRY THIS: change this to "3 - index" and see how the order changes.
                    order: index,
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
                  String order =
                  String.fromCharCode('A'.codeUnitAt(0) + (2 - index));
                  return OrderedButton<String>(
                    name: 'String: $order',
                    order: order,
                  );
                }),
              ),
            ),
            // A group that orders in widget order, regardless of what the order is set to.
            FocusTraversalGroup(
              // Note that because this is NOT an OrderedTraversalPolicy, these
              // "OrderedButtons" their assigned order is ignored, and they are
              // traversed in widget order.
              // TRY THIS: change this to "OrderedTraversalPolicy()" and see that
              // it now follows the order set instead of widget order.
              policy: WidgetOrderTraversalPolicy(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(3, (int index) {
                  return OrderedButton<num>(
                    name: 'ignored num: ${3 - index}',
                    order: 3 - index,
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
