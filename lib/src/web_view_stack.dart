import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Just define WebViewStack
class WebViewStack extends StatefulWidget {
  // create a new instance of the WebViewStack widget.
  // this.controller is WebViewController.
  // super.key is calling the constructor's key of StatefulWidget.
  // assign super.key to WebViewStack widget.
  const WebViewStack({required this.controller, super.key});

  // Define controller
  final WebViewController controller;

  // Override createState method in StatefulWidget
  @override
  // create and return a new instance of _WebViewAppState
  // as the state object for the WebViewApp widget.
  State<WebViewStack> createState() => _WebViewStackState();
}

// Just define _WebViewStackState
class _WebViewStackState extends State<WebViewStack> {
  // variable of how loading number to use progress bar
  var loadingPercentage = 0;

  // Initialisation of the state.
  @override
  void initState() {
    // Initialisation of the state in initState method
    super.initState();
    widget.controller
      ..setNavigationDelegate(
        NavigationDelegate(
          // When start loading
          onPageStarted: (url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          // When on the way to loading
          onProgress: (progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          // When complete loading
          onPageFinished: (url) {
            setState(() {
              loadingPercentage = 100;
            });
          },
          // Check Url request is correct
          onNavigationRequest: (navigation) {
            // Get host url
            final host = Uri.parse(navigation.url).host;
            // In case of the host url contains the following url.
            if (host.contains('youtube.com')) {
              // Show snackBar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Blocking navigation to $host',
                  ),
                ),
              );
              // prevent to moving the host url.
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      // let use javascript
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // set javascript channel and the channel is snackbar.
      ..addJavaScriptChannel(
        'SnackBar',
        onMessageReceived: (message) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message.message)));
        },
      );
  }

  // Create the page of webview part.
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // WebView part
        WebViewWidget(
          controller: widget.controller,
        ),
        // Progress bar when loadingPercentage is less than 100.
        if (loadingPercentage < 100)
          LinearProgressIndicator(
            value: loadingPercentage / 100.0,
          ),
      ],
    );
  }
}
