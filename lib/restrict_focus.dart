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
  WidgetsApp.debugAllowBannerOverride = false;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const String title = 'Restrict Focus Example';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      // Make the focus highlight a little darker than usual to make it more
      // obvious.
      theme: ThemeData(focusColor: Colors.black38),
      home: PageWithBackdrop(title: title),
    );
  }
}

class PageWithBackdrop extends StatefulWidget {
  PageWithBackdrop({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PageWithBackdropState createState() => _PageWithBackdropState();
}

class _PageWithBackdropState extends State<PageWithBackdrop> {
  bool backdropIsVisible = false;
  FocusNode backdropNode = FocusNode(debugLabel: 'Close Backdrop Button');
  FocusNode foregroundNode = FocusNode(debugLabel: 'Option Button');

  @override
  void dispose() {
    super.dispose();
    backdropNode.dispose();
    foregroundNode.dispose();
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    Size stackSize = constraints.biggest;
    return Stack(
      fit: StackFit.expand,
      // The backdrop is behind the front widget in the Stack, but the widgets
      // would still be active and traversable without the FocusScope.
      children: <Widget>[
        // TRY THIS: Try removing this FocusScope entirely to see how it affects
        // the behavior. Without this FocusScope, the "ANOTHER BUTTON TO FOCUS"
        // button, and the IconButton in the backdrop Pane would be focusable
        // even when the backdrop wasn't visible.
        FocusScope(
          // TRY THIS: Try commenting out this line. Notice that the focus
          // starts on the backdrop and is stuck there? It seems like the app is
          // non-responsive, but it actually isn't. This line makes sure that
          // this focus scope and its children can't be focused when they're not
          // visible. It might help to make the background color of the
          // foreground pane semi-transparent to see it clearly.
          canRequestFocus: backdropIsVisible,
          child: Pane(
            icon: Icon(Icons.close),
            focusNode: backdropNode,
            backgroundColor: Colors.lightBlue,
            onPressed: () => setState(() => backdropIsVisible = false),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // This button would be not visible, but still focusable from
                // the foreground pane without the FocusScope.
                RaisedButton(
                  onPressed: () => print('You pressed the other button!'),
                  child: Text('ANOTHER BUTTON TO FOCUS'),
                ),
                DefaultTextStyle(style: Theme.of(context).textTheme.display3, child: Text('BACKDROP')),
              ],
            ),
          ),
        ),
        AnimatedPositioned(
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 300),
          top: backdropIsVisible ? stackSize.height * 0.9 : 0.0,
          width: stackSize.width,
          height: stackSize.height,
          onEnd: () {
            if (backdropIsVisible) {
              backdropNode.requestFocus();
            } else {
              foregroundNode.requestFocus();
            }
          },
          child: Pane(
            icon: Icon(Icons.menu),
            focusNode: foregroundNode,
            // TRY THIS: Try changing this to Colors.green.withOpacity(0.8) to see for
            // yourself that the hidden components do/don't get focus.
            backgroundColor: Colors.green,
            onPressed: backdropIsVisible ? null : () => setState(() => backdropIsVisible = true),
            child: DefaultTextStyle(style: Theme.of(context).textTheme.display3, child: Text('FOREGROUND')),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // Use a LayoutBuilder so that we can base the size of the stack on the
      // size of its parent.
      body: LayoutBuilder(builder: _buildStack),
    );
  }
}

/// A demonstration pane.
///
/// This is just a separate widget to simplify the example above.
class Pane extends StatelessWidget {
  const Pane({
    Key key,
    this.focusNode,
    this.onPressed,
    this.child,
    this.backgroundColor,
    this.icon,
  }) : super(key: key);

  final FocusNode focusNode;
  final VoidCallback onPressed;
  final Widget child;
  final Color backgroundColor;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: child,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              autofocus: true,
              focusNode: focusNode,
              onPressed: onPressed,
              icon: icon,
            ),
          ),
        ],
      ),
    );
  }
}
