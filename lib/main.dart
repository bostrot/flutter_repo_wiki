import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'screens/pub.dart';
import 'screens/docs.dart';
import 'screens/favorite.dart';
import 'components/api.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

final flutterWebviewDocsPlugin = new FlutterWebviewPlugin();
TabController tabController;
FirebaseAnalytics analytics = new FirebaseAnalytics();
int counter = 0;

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Repo Notifier',
      theme: new ThemeData(
          primarySwatch: Colors.blue,
          backgroundColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          hintColor: Colors.grey,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: Colors.black,
                displayColor: Colors.grey,
              )),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
      navigatorObservers: [
        new FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    tabController = new TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    width = width * 0.65;
    return new Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          elevation: 0.0,
          bottom: TabBar(
            controller: tabController,
            tabs: [
              Tab(icon: Icon(Icons.public)),
              Tab(icon: Icon(Icons.star)),
              Tab(icon: Icon(Icons.assignment)),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          //https://flutter.io/search/?q=text,
          Pub(),
          FavoriteScreen(),
          DocsScreen(),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

launchWebview(BuildContext context) {
  flutterWebviewDocsPlugin.launch(
    "https://flutter.io/search/",
    rect: new Rect.fromLTWH(
        0.0,
        (kToolbarHeight + 21).toDouble(),
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height - kToolbarHeight),
    withJavascript: true,
  );
}
