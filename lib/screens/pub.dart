import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:share/share.dart';

import 'package:package_notifier/components/api.dart';

String currentURL;

bool starred = false;
bool loading = true;
int currentPage = 0;
List packages = [];

class Pub extends StatefulWidget {
  @override
  PubState createState() => new PubState();
}

class PubState extends State<Pub> {
  var packageData;

  getData(String package) async {
    var _tempData;

    if (package != null) {
      // get a single package with name from pub
      _tempData = await Packages().getSingle(package);
      return (_tempData);
    } else {
      // get first page from pub
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

  // build package list with 100 items
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Packages().getPage(currentPage),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          packages.addAll(snapshot.data["packages"]);
          return packageListView();
        } else
          return Center(child: CircularProgressIndicator());
      },
    );
  }

  packageListView() {
    return ListView.builder(
        itemCount: packages.length,
        itemBuilder: (BuildContext context, int index) {
          var _data = packages[index];
          var _pubspec = _data["latest"]["pubspec"];
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.all(14.0),
              child: TextField(
                  decoration: InputDecoration(hintText: "Search..."),
                  onSubmitted: (str) {
                    print("pressed 2");
                    packageScreen(context, str);
                  }),
            );
          } else if (index == packages.length - 1) {
            // Load more
            setState(() {
              currentPage++;
            });
          }
          return ListTile(
            onTap: () {
              print("pressed3");
              packageScreen(context, _data["name"]);
            },
            title: Text(_data["name"]),
            trailing: _pubspec["author"] != null
                ? (Container(
                    color: Colors.blue,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(_pubspec["author"].split("<")[0],
                          style:
                              TextStyle(color: Colors.white, fontSize: 12.0)),
                    ),
                  ))
                : Text(""),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(_pubspec["description"] + "\nv" + _pubspec["version"]),
                Divider()
              ],
            ),
          );
        });
  }
}

// this handles the toolbar above of the webview
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
    print("init state");
    flutterWebviewPlugin = new FlutterWebviewPlugin();
    favoriteHandler();
    flutterWebviewPlugin.onStateChanged.listen((state) async {
      stateChange(state, context);
    });
    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      currentURL = url;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new WebviewScaffold(
      url: "https://pub.dev/packages/${widget.str}",
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
                // get package name from current url and set as favorite or remove
                if (!starred) {
                  favorite(widget.str, false);
                } else {
                  favorite(widget.str, true);
                }
              }),
        ],
        title: new Text(widget.str),
      ),
      initialChild: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// start webview hidden while loading
packageScreen(BuildContext context, str) {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => PackageScreen(str)));
}
