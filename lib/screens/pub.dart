import 'package:flutter/material.dart';
import '../components/api.dart';
import 'dart:async';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:share/share.dart';
import 'docs.dart';

String currentURL;

bool starred = false;
bool loading = true;

class Pub extends StatefulWidget {
  @override
  PubState createState() => new PubState();
}

class PubState extends State<Pub> {
  var packageData;

  getData(String package) async {
    var _tempData;

    if (package != null) {
      _tempData = await Packages().getSingle(package);
      return (_tempData);
    } else {
      _tempData = await Packages().getPage(1);
    }
    setState(() {
      packageData = _tempData;
    });
  }

  @override
  void initState() {
    getData(null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return packageData != null
        ? ListView.builder(
            itemCount: 101,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: TextField(
                      decoration: InputDecoration(hintText: "Search..."),
                      onSubmitted: (str) {
                        packageScreen(context, str);
                      }),
                );
              } else {
                var _data = packageData["packages"][index - 1];
                var _pubspec = _data["latest"]["pubspec"];
                return ListTile(
                  onTap: () {
                    packageScreen(context, _data["name"]);
                  },
                  title: Text(_data["name"]),
                  trailing: _pubspec["author"] != null
                      ? (Container(
                          color: Colors.blue,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(_pubspec["author"].split("<")[0],
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12.0)),
                          ),
                        ))
                      : Text(""),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(_pubspec["description"] +
                          "\nv" +
                          _pubspec["version"]),
                      Divider()
                    ],
                  ),
                );
              }
            })
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}

class PackageScreen extends StatefulWidget {
  final String str;
  PackageScreen(
    this.str,
  );
  @override
  State<StatefulWidget> createState() => PackageScreenState();
}

class PackageScreenState extends State<PackageScreen> {
  favoriteHandler() async {
    bool _temp = await favorite(widget.str, null);
    setState(() {
      starred = _temp;
    });
  }

  @override
  void initState() {
    favoriteHandler();
    onStateChanged =
        flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      stateChange(state, context);
    });

    onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      setState(() {
        currentURL = url;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        appBar: new AppBar(
          elevation: 0.0,
          automaticallyImplyLeading: false,
          leading: new Row(
            textDirection: TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new IconButton(
                icon: new Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  flutterWebviewPlugin.close();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: <Widget>[
            new IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                Share.share(currentURL);
              },
            ),
            new IconButton(
                icon: starred ? Icon(Icons.star) : Icon(Icons.star_border),
                onPressed: () {
                  setState(() {
                    starred = !starred;
                  });
                  if (!starred) {
                    favorite(
                        currentURL.split("packages/")[1].split("#")[0], false);
                  } else if (currentURL != null) {
                    favorite(
                        currentURL.split("packages/")[1].split("#")[0], true);
                  }
                }),
          ],
          title: new Text(widget.str),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    flutterWebviewPlugin.close();
    Navigator.pop(context);
  }
}

packageScreen(BuildContext context, str) {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => PackageScreen(str)));
  flutterWebviewPlugin.launch(
    "https://pub.dartlang"
        ".org/packages/" +
        str,
    rect: new Rect.fromLTWH(0.0, 0.0, 0.0, 0.0),
    withJavascript: true,
  );
}
