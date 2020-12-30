import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/*
    This file contains most api requests and public functions.
 */

FlutterWebviewPlugin flutterWebviewPlugin;
StreamSubscription<WebViewStateChanged> onStateChanged;
StreamSubscription<String> onUrlChanged;

class Packages {
  Dio dio = new Dio();
  Response response;
  var packageData;

  // get a single package from the dart pub api
  // returns best fitting package to the string name
  getSingle(String package) async {
    packageData = await dio.get("https://pub.dev/api/packages/" + package);
    return (packageData.data);
  }

  // get a page from the dart pub api
  getPage(int page) async {
    packageData =
        await dio.get("https://pub.dev/api/packages?page" + page.toString());
    return (packageData.data);
  }
}

// launch in app browser
launchURL(String url, ctx) async {
  flutterWebviewPlugin = new FlutterWebviewPlugin();
  flutterWebviewPlugin.onStateChanged.listen((state) async {
    stateChange(state, ctx);
  });
  return new WebviewScaffold(
    url: url,
    appBar: new AppBar(
      title: const Text('Widget webview'),
    ),
    withZoom: true,
    withLocalStorage: true,
    hidden: true,
    initialChild: Container(
      color: Colors.redAccent,
      child: const Center(
        child: Text('Waiting.....'),
      ),
    ),
  );
}

// get all items on favorite list
listFavorite() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var _temp = prefs.getStringList("favorites");
  return (_temp);
}

// set and remove items on the favorite list
favorite(String name, bool fav) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // get current favorites
  List<String> favorites = prefs.getStringList("favorites");
  if (favorites == null) {
    favorites = <String>[];
  }
  if (fav == null) {
    // just check if list contains string
    if (favorites.indexOf(name) > -1) {
      return true;
    } else {
      return false;
    }
  } else if (fav) {
    // set to true
    favorites.add(name);
  } else if (!fav) {
    // set to false
    favorites.remove(name);
  }
  prefs.setStringList("favorites", favorites);
}

// launch url in a browser
launchExternalURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

// handle webview state change
stateChange(var state, BuildContext context) {
  print("StateChanged: " + state.toString());

  // when clicked on url that is not a package url, open in browser and goback
  if ((state.url).indexOf("https://pub.dev/packages") < 0) {
    flutterWebviewPlugin.goBack();
    launchExternalURL(state.url);
  } else if (state.type == WebViewState.finishLoad) {
    // set both headers to display: none - hide them
    flutterWebviewPlugin.evalJavascript(
        'var css = document.createElement("style"); css.type = "text/css";css'
        '.innerHTML = ".site-header { display: none; } ._banner-bg { display: '
        'none; } .detail-header.-is-loose { padding-top: 10px; }";document.body'
        '.appendChild(css);');
  }
}
