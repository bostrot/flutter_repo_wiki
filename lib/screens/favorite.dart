import 'package:flutter/material.dart';

//import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../components/api.dart';
import 'pub.dart';

var keys;
var versions = [];

//FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//    new FlutterLocalNotificationsPlugin();

class FavoriteScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FavoriteScreenState();
}

class FavoriteScreenState extends State<FavoriteScreen> {
  // get favorites from shared preferences them get version data from pub server
  list() async {
    try {
      var _keys = await listFavorite();
      setState(() {
        keys = _keys;
      });
      for (int i = 0; i < _keys.length; i++) {
        var _temp = (await Packages().getSingle(_keys[i]));
        versions.add(_temp["latest"]["pubspec"]["version"]);
      }

      setState(() {
        versions = versions;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
//    var initializationSettingsAndroid =
//        new AndroidInitializationSettings('app_icon');
//    var initializationSettingsIOS = new IOSInitializationSettings();
//    var initializationSettings = new InitializationSettings(
//     android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    /*flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (s) {});*/
    // TODO: notify on package update
    list();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (keys != null && versions != null && keys.length > 0) {
      return ListView.builder(
          itemCount: keys.length,
          itemBuilder: (context, index) {
            try {
              return ListTile(
                title: Text(keys[index]),
                trailing: Container(
                  color: Colors.blue,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      versions[index],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                onTap: () {
                  print("pressed");
                  packageScreen(context, keys[index]);
                },
              );
            } catch (e) {
              return Container();
            }
          });
    } else {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("No favorites yet."),
          ),
        ],
      );
    }
  }
}
