import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'src/menu.dart';
import 'src/navigation_controls.dart';
import 'src/web_view_stack.dart';

// This is entry point of this app.
// Execute main method.
void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(useMaterial3: true), // Set theme as material design 3
      home: WebViewApp(), // Set the top page
    ),
  );
}

// Just define WebViewApp class
class WebViewApp extends StatefulWidget {
  // create a new instance of the WebViewApp widget.
  // super.key is calling the constructor's key of StatefulWidget.
  // assign the StatefulWidget key to WebViewApp widget.
  const WebViewApp({super.key});

  // Override createState method in StatefulWidget
  @override
  // create and return a new instance of _WebViewAppState
  // as the state object for the WebViewApp widget.
  State<WebViewApp> createState() => _WebViewAppState();
}

// Just define _WebViewAppState class
class _WebViewAppState extends State<WebViewApp> {
  // late denotes that a non-nullable variable will be initialized later in the code.
  // WebViewController is responsible for controlling and managing the web view.
  late final WebViewController controller;

  // Initialisation of the state.
  @override
  void initState() {
    // Initialisation of the state in initState method
    super.initState();
    // new controller.
    controller = WebViewController()
      // Loading page for the url.
      ..loadRequest(
        Uri.parse('https://flutter.dev'),
      );
  }

  // Create the top page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebView'), // Nav title
        actions: [
          NavigationControls(controller: controller), // Navigation button
          Menu(controller: controller), // Menu button
        ],
      ),
      // the body is webview.
      body: WebViewStack(controller: controller),
    );
  }
}
