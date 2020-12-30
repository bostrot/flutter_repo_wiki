import 'package:flutter/material.dart';

import 'screens/docs.dart';
import 'screens/favorite.dart';
import 'screens/pub.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Repo Notifier',
      // theme data
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
      home: new MyHomePage(title: 'Flutter'),
      // some firebase analytics
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: new Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBar(
            elevation: 0.0,
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.public)),
                Tab(icon: Icon(Icons.star)),
                Tab(icon: Icon(Icons.assignment)),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            Pub(), // packages screen
            FavoriteScreen(), // favorite screen
            DocsScreen(), // documentation screen
          ],
        ),
      ),
    );
  }
}
