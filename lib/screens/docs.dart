import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_notifier/components/api.dart';
import 'package:html/parser.dart' show parse;

class DocsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DocsScreenState();
}

var docData;

class DocsScreenState extends State<DocsScreen> {
  // parse docs from flutter.io per html
  getDocs() async {
    Dio dio = new Dio();
    var _tempDocs = await dio.get("https://flutter.io/docs/");
    var document = parse(_tempDocs.data);
    setState(() {
      docData = document.querySelector(".site-sidebar").querySelectorAll("a");
    });
  }

  @override
  void initState() {
    getDocs();
    super.initState();
  }

  // build item list with search bar above
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
                hintText: "Searc"
                    "h docs..."),
            onSubmitted: (str) {
              launchExternalURL(
                  "https://flutter.io/search/?ie=UTF-8&hl=en&q=" + str);
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
                            trailing: Icon(Icons.open_in_new),
                            onTap: () {
                              launchExternalURL("https://flutter.io" + _url);
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
      ],
    );
  }
}
