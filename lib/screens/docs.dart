import 'package:flutter/material.dart';
import 'package:package_notifier/components/api.dart';
import 'package:html/parser.dart' show parse;

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_html_view/flutter_html_view.dart';

var _onStateChanged;
FlutterWebviewPlugin flutterWebviewDocs = new FlutterWebviewPlugin();

class DocsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DocsScreenState();
}

var docData;

class DocsScreenState extends State<DocsScreen> {
  getDocs() async {
    Dio dio = new Dio();
    var _tempDocs = await dio.get("https://flutter.io/docs/");
    var document = parse(_tempDocs.data);
    setState(() {
      docData = document.querySelector("#mysidebar").querySelectorAll("li");
    });
    print(docData);
  }

  @override
  void initState() {
    getDocs();
    super.initState();
  }

  var item = [new ListTile()];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
                hintText: "Searc"
                    "h docs..."),
            onSubmitted: (str) {
              launchURL("https://flutter.io/search/?ie=UTF-8&hl=en&q=" + str,
                  context);
            },
          ),
        ),
        docData != null
            ? Expanded(
                child: new ListView.builder(
                    itemCount: docData.length,
                    itemBuilder: (BuildContext context, int index) {
                      var _name = docData[index].text;
                      try {
                        var _url =
                            (parse(docData[index].outerHtml).querySelector("a"))
                                .attributes["href"];
                        return ListTile(
                            title: Text(_name),
                            leading: Container(child: Text("")),
                            trailing: Icon(Icons.open_in_new),
                            onTap: () {
                              launchURL("https://flutter.io" + _url, context);
                            });
                      } catch (e) {
                        print(docData[index]);
                        return ListTile(
                          title: Text(
                            _name,
                            style: TextStyle(fontSize: 14.0),
                          ),
                        );
                      }
                    }))
            : CircularProgressIndicator()
        /*Builder(
            builder: (context) {
              const double pictureHeight = 100.0;
              const double pictureWidth = 100.0;
              print(parse('<body>Hello world! <a href="www.html5rocks.com">HTML5 '
                  'rocks!'));
              String someText =
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                      " Vivamus sed lacus vitae ante aliquet fermentum non "
                      "sit amet purus. Suspendisse consequat, augue vitae "
                      "condimentum malesuada, neque enim commodo justo, "
                      "quis gravida metus felis ac tortor. Fusce ut eros "
                      "orci. Maecenas nec luctus arcu. In lorem quam, "
                      "imperdiet at ante nec, ullamcorper sollicitudin "
                      "augue. Aenean id viverra neque. Duis commodo vitae "
                      "orci dictum scelerisque. " +
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                      " Vivamus sed lacus vitae ante aliquet fermentum non "
                      "sit amet purus. Suspendisse consequat, augue vitae "
                      "condimentum malesuada, neque enim commodo justo, "
                      "quis gravida metus felis ac tortor. Fusce ut eros "
                      "orci. Maecenas nec luctus arcu. In lorem quam, "
                      "imperdiet at ante nec, ullamcorper sollicitudin "
                      "augue. Aenean id viverra neque. Duis commodo vitae "
                      "orci dictum scelerisque. ";
              return Stack(
                children: <Widget>[
                  Image.network(
                    "https://www.beautifulpeople"
                        ".com/cdn/beautifulpeople/images/default_profile"
                        "/signup_male.png",
                    height: pictureHeight,
                    width: pictureWidth,
                  ),
                ],
              );
            },
          )*/
      ],
    );
  }
}

Widget aligned(String text) {
  for (int i = 0; i < text.length; i++) {}
  return null;
}
