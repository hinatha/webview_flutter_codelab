import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Set HTML as String type
const String kExamplePage = '''
<!DOCTYPE html>
<html lang="en">
<head>
<title>Load file or HTML string example</title>
</head>
<body>

<h1>Local demo page</h1>
<p>
  This is an example page used to demonstrate how to load a local file or HTML
  string using the <a href="https://pub.dev/packages/webview_flutter">Flutter
  webview</a> plugin.
</p>

</body>
</html>
''';

// Set MenuOption as enum
enum _MenuOptions {
  navigationDelegate,
  userAgent,
  javascriptChannel,
  listCookies,
  clearCookies,
  addCookie,
  setCookie,
  removeCookie,
  loadFlutterAsset,
  loadLocalFile,
  loadHtmlString,
}

// Just define Menu class.
class Menu extends StatefulWidget {
  // create a new instance of the Menu widget.
  // this.controller is WebViewController.
  // super.key is calling the constructor's key of StatefulWidget.
  // assign super.key to Menu widget.
  const Menu({required this.controller, super.key});

  // Define controller
  final WebViewController controller;

  // Override createState method in StatefulWidget
  @override
  // create and return a new instance of _MenuState
  // as the state object for the WebViewApp widget.
  State<Menu> createState() => _MenuState();
}

// Just define _MenuState class
class _MenuState extends State<Menu> {
  // New cookie manager.
  final cookieManager = WebViewCookieManager();

  // Create the page of menu button part.
  @override
  Widget build(BuildContext context) {
    // About menu button
    return PopupMenuButton<_MenuOptions>(
      // value is the defined enum
      onSelected: (value) async {
        switch (value) {
          case _MenuOptions.navigationDelegate:
            // Request moving to youtube.com
            await widget.controller
                .loadRequest(Uri.parse('https://youtube.com'));
            break;
          case _MenuOptions.userAgent:
            final userAgent = await widget.controller
                .runJavaScriptReturningResult('navigator.userAgent');
            if (!mounted) return;
            // Show userAgent as SnackBar
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('$userAgent'),
            ));
            break;
          case _MenuOptions.javascriptChannel:
            // Run JavaScript to get IP Address
            await widget.controller.runJavaScript('''
var req = new XMLHttpRequest();
req.open('GET', "https://api.ipify.org/?format=json");
req.onload = function() {
  if (req.status == 200) {
    let response = JSON.parse(req.responseText);
    SnackBar.postMessage("IP Address: " + response.ip);
  } else {
    SnackBar.postMessage("Error: " + req.status);
  }
}
req.send();''');
            break;
          case _MenuOptions.clearCookies:
            await _onClearCookies();
            break;
          case _MenuOptions.listCookies:
            await _onListCookies(widget.controller);
            break;
          case _MenuOptions.addCookie:
            await _onAddCookie(widget.controller);
            break;
          case _MenuOptions.setCookie:
            await _onSetCookie(widget.controller);
            break;
          case _MenuOptions.removeCookie:
            await _onRemoveCookie(widget.controller);
            break;
          case _MenuOptions.loadFlutterAsset:
            await _onLoadFlutterAssetExample(widget.controller, context);
            break;
          case _MenuOptions.loadLocalFile:
            await _onLoadLocalFileExample(widget.controller, context);
            break;
          case _MenuOptions.loadHtmlString:
            await _onLoadHtmlStringExample(widget.controller, context);
            break;
        }
      },
      // Set the each menu title
      itemBuilder: (context) => [
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.navigationDelegate,
          child: Text('Navigate to YouTube'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.userAgent,
          child: Text('Show user-agent'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.javascriptChannel,
          child: Text('Lookup IP Address'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.clearCookies,
          child: Text('Clear cookies'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.listCookies,
          child: Text('List cookies'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.addCookie,
          child: Text('Add cookie'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.setCookie,
          child: Text('Set cookie'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.removeCookie,
          child: Text('Remove cookie'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.loadFlutterAsset,
          child: Text('Load Flutter Asset'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.loadHtmlString,
          child: Text('Load HTML string'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.loadLocalFile,
          child: Text('Load local file'),
        ),
      ],
    );
  }

  Future<void> _onListCookies(WebViewController controller) async {
    final String cookies = await controller
        .runJavaScriptReturningResult('document.cookie') as String;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(cookies.isNotEmpty ? cookies : 'There are no cookies.'),
      ),
    );
  }

  Future<void> _onClearCookies() async {
    final hadCookies = await cookieManager.clearCookies();
    String message = 'There were cookies. Now, they are gone!';
    if (!hadCookies) {
      message = 'There were no cookies to clear.';
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _onAddCookie(WebViewController controller) async {
    await controller.runJavaScript('''var date = new Date();
  date.setTime(date.getTime()+(30*24*60*60*1000));
  document.cookie = "FirstName=John; expires=" + date.toGMTString();''');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom cookie added.'),
      ),
    );
  }

  Future<void> _onSetCookie(WebViewController controller) async {
    await cookieManager.setCookie(
      const WebViewCookie(name: 'foo', value: 'bar', domain: 'flutter.dev'),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom cookie is set.'),
      ),
    );
  }

  Future<void> _onRemoveCookie(WebViewController controller) async {
    await controller.runJavaScript(
        'document.cookie="FirstName=John; expires=Thu, 01 Jan 1970 00:00:00 UTC" ');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom cookie removed.'),
      ),
    );
  }

  // Show HTML included css.
  Future<void> _onLoadFlutterAssetExample(
      WebViewController controller, BuildContext context) async {
    await controller.loadFlutterAsset('assets/www/index.html');
  }

  // Show HTML defined in assets/www/index.html as String
  Future<void> _onLoadLocalFileExample(
      WebViewController controller, BuildContext context) async {
    final String pathToIndex = await _prepareLocalFile();

    await controller.loadFile(pathToIndex);
  }

  // Load local HTML file as String
  static Future<String> _prepareLocalFile() async {
    final String tmpDir = (await getTemporaryDirectory()).path;
    final File indexFile = File('$tmpDir/www/index.html');

    await Directory('$tmpDir/www').create(recursive: true);
    await indexFile.writeAsString(kExamplePage);

    return indexFile.path;
  }

  // Show HTML defined in this file.
  Future<void> _onLoadHtmlStringExample(
      WebViewController controller, BuildContext context) async {
    await controller.loadHtmlString(kExamplePage);
  }
}
