
  
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String url = "https://owlbot.info/api/v4/dictionary/";
  String token = " b5726694ee5681ac991230d447e0881e6d06c6be";

  TextEditingController textEditingController = TextEditingController();

  // Stream for loading the text as soon as it is typed
  late StreamController streamController;
  late Stream _stream;

  late Timer _debounce;

  // search function
  find() async {
    if (textEditingController.text == null ||
        textEditingController.text.length == 0) {
      streamController.add(null);
      return;
    }
    streamController.add("waiting");
    Response response = await get(Uri.parse(url + textEditingController.text.trim()),
        // do provide spacing after Token
        headers: {"Authorization": "Token " + token});
    streamController.add(json.decode(response.body));
  }

  

  @override
  void initState() {
    super.initState();
    streamController = StreamController();
    _stream = streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          "Dictionary",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(45),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 12, bottom: 11.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      color: Colors.white),
                  child: TextFormField(
                    onChanged: (String text) {
                      if (_debounce?.isActive ?? false) _debounce.cancel();
                      _debounce = Timer(const Duration(milliseconds: 1000), () {
                        find();
                      });
                    },
                    controller: textEditingController,
                    decoration: InputDecoration(
                      hintText: "Enter a word to Search ",
                      contentPadding: const EdgeInsets.only(left: 24.0),

                      // removing the input border
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  find();
                },
              )
            ],
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(8),
        child: StreamBuilder(
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: Text(" Search a word"),
              );
            }
            if (snapshot.data == "waiting") {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            // output
            return ListView.builder(
              itemCount: snapshot.data["definitions"].length,
              itemBuilder: (BuildContext context, int index) {
                return ListBody(
                  children: [
                    Container(
                      color: Colors.purple.shade100,
                      child: ListTile(
                        leading: snapshot.data["definitions"][index]
                                    ["image_url"] ==
                                null
                            ? null
                            : CircleAvatar(
                                backgroundImage: NetworkImage(snapshot
                                    .data["definitions"][index]["image_url"]),
                              ),
                        title: Text(textEditingController.text.trim() +
                            "(" +
                            snapshot.data["definitions"][index]["type"] +
                            ")"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          snapshot.data["definitions"][index]["definition"]),
                    )
                  ],
                );
              },
            );
          },
          stream: _stream,
        ),
      ),
    );
  }
}
