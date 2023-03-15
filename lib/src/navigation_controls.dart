import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Just define NavigationControls
class NavigationControls extends StatelessWidget {
  // create a new instance of the NavigationControls widget.
  // this.controller is WebViewController.
  // super.key is calling the constructor's key of StatelessWidget.
  // assign super.key to NavigationControls widget.
  const NavigationControls({required this.controller, super.key});

  // Define controller
  final WebViewController controller;

  // Create the page of navigation controls part.
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // Go back to former page button
        IconButton(
          icon: const Icon(Icons.arrow_back_ios), // set button icon like "<".
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            // In case of going back
            if (await controller.canGoBack()) {
              await controller.goBack();
            } else {
              // In case of not going back
              // show the message of can't go back
              messenger.showSnackBar(
                const SnackBar(content: Text('No back history item')),
              );
              return;
            }
          },
        ),
        // Go to forward page button
        IconButton(
          icon:
              const Icon(Icons.arrow_forward_ios), // set button icon like ">".
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            // In case of going forward
            if (await controller.canGoForward()) {
              await controller.goForward();
            } else {
              // In case of not going forward
              // show the message of can't go forward
              messenger.showSnackBar(
                const SnackBar(content: Text('No forward history item')),
              );
              return;
            }
          },
        ),
        // Reload the page button
        IconButton(
          icon: const Icon(Icons.replay), // set the button icon
          onPressed: () {
            controller.reload(); // Execute reloading the page
          },
        ),
      ],
    );
  }
}
