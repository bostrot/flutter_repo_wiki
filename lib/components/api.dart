import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as cTab;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'dart:async';

final flutterWebviewPlugin = new FlutterWebviewPlugin();
StreamSubscription<WebViewStateChanged> onStateChanged;
StreamSubscription<String> onUrlChanged;

class Packages {
  Dio dio = new Dio();
  Response response;
  var packageData;

  getSingle(String package) async {
    packageData = await dio.get("https://pub.dartlang"
        ".org/api/packages/" +
        package);
    return (packageData.data);
  }

  getPage(int page) async {
    packageData = await dio.get("https://pub.dartlang"
        ".org/api/packages?page" +
        page.toString());
    return (packageData.data);
  }
}

void launchURL(String url, ctx) async {
  try {
    await cTab.launch(
      url,
      option: new cTab.CustomTabsOption(
        toolbarColor: Theme.of(ctx).primaryColor,
        enableDefaultShare: true,
        enableUrlBarHiding: true,
        showPageTitle: true,
      ),
    );
  } catch (e) {
    // An exception is thrown if browser app is not installed on Android device.
    debugPrint(e.toString());
  }
}

listFavorite() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var _temp = prefs.getStringList("favorites");
  return (_temp);
}

favorite(String name, bool fav) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // get current favorites
  List<String> favorites = prefs.getStringList("favorites");
  print(favorites);
  if (favorites == null) {
    favorites = <String>[];
  }
  print(fav);
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

removeFavorite(String name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    prefs.remove(name);
  } catch (e) {}
}

launchExternalURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

stateChange(var state, BuildContext context) {
  print("StateChanged: " + state.toString());
  flutterWebviewPlugin.evalJavascript(
      'var css = document.createElement("style"); css.type = "text/css";css'
      '.innerHTML = ".site-header { display: none; } ._banner-bg { display: '
      'none; }";document.body'
      '.appendChild(css);');
  flutterWebviewPlugin.resize(Rect.fromLTWH(0.0, 0.0, 0.0, 0.0));
  if ((state.url).indexOf("https://pub.dartlang"
          ".org/packages") <
      0) {
    flutterWebviewPlugin.goBack();
    launchExternalURL(state.url);
  } else if (state.type == WebViewState.finishLoad) {
    flutterWebviewPlugin.resize(Rect.fromLTWH(
        0.0,
        (kToolbarHeight + 21).toDouble(),
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height - kToolbarHeight));
  }
}
