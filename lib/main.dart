import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';

class DictionaryStorage {
  Future<dynamic> loadAsset(BuildContext context) async {
    final lst =
        await DefaultAssetBundle.of(context).loadString('db/dictionary.json');
    final _dictionaryData = json.decode(lst);
    return _dictionaryData;
  }
}

class Word {
  final String key;
  final String content;

  Word(this.key, this.content);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dictionary App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Dictionary(storage: DictionaryStorage(), title: 'Dictionary'),
    );
  }
}

class Dictionary extends StatefulWidget {
  const Dictionary({Key? key, required this.storage, required this.title})
      : super(key: key);

  final DictionaryStorage storage;
  final String title;

  @override
  State<Dictionary> createState() => _DictionaryState();
}

class _DictionaryState extends State<Dictionary> {
  dynamic _dictionaryData;
  bool modeFind = false;
  List<Word> words = [];
  List<Word> wordFinds = [];
  List<Word> wordFindsClone = [];
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    widget.storage.loadAsset(context).then((dynamic obj) {
      setState(() {
        _dictionaryData = obj;
        _dictionaryData.keys.forEach((key) {
          words.add(Word(key, _dictionaryData[key]));
        });
      });
    });
  }

  Widget buildWordList() {
    return Container(
        padding: const EdgeInsets.only(top: 20),
        child: SizedBox(
            height: 550,
            child: Expanded(
                child: ListView.builder(
                    itemCount: words.length,
                    itemBuilder: (BuildContext context, int i) {
                      return ListTile(
                        title: Text(words[i].key),
                        subtitle: Text(
                          buildString(words[i].content),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (
                              context,
                            ) =>
                                    WordScreen(
                                        Texta: words[i].content,
                                        Textb: words[i].key)),
                          );
                        },
                      );
                    }))));
  }

  String buildString(String word) {
    final arr = word.split(" ");
    String a = "";
    if (arr.length > 20) {
      for (int i = 0; i < 20; i++) {
        a = a + " " + arr[i];
      }
      return a;
    } else {
      return arr.join(" ");
    }
  }

  Widget buildFindList() {
    return Container(
        padding: const EdgeInsets.only(top: 20),
        child: SizedBox(
            height: 550,
            child: Expanded(
                child: ListView.builder(
                    itemCount: wordFinds.length,
                    itemBuilder: (BuildContext context, int i) {
                      return ListTile(
                        title: Text(wordFinds[i].key),
                        subtitle: Text(
                          buildString(words[i].content),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (
                              context,
                            ) =>
                                    WordScreen(
                                      Texta: wordFinds[i].content,
                                      Textb: wordFinds[i].key,
                                    )),
                          );
                        },
                      );
                    }))));
  }

  Widget buildFind() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: TextField(
        controller: _controller,
        onChanged: (String value) {
          setState(() {
            String text = _controller.text;
            if (text == "") {
              modeFind = false;
              wordFinds = [];
            } else {
              modeFind = true;
              wordFinds = [];
              for (Word word in words) {
                if (word.key == text) {
                  wordFinds.add(word);
                }
              }
              if (wordFinds.length == 0) {
                for (Word word in words) {
                  if (word.key.contains(text)) {
                    wordFinds.add(word);
                  }
                }
              }
              ;
            }
          });
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Entry word",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildFind(),
            modeFind ? buildFindList() : buildWordList(),
          ],
        ));
  }
}

class WordScreen extends StatelessWidget {
  final String Texta;
  final String Textb;
  const WordScreen({Key? key, required this.Texta, required this.Textb})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Detail Word',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          appBar: AppBar(
              title: Text("Detail"),
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back))),
          body: Container(
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 5, bottom: 20),
                      child: Align(
                          child: Text(Textb,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              )),
                          alignment: Alignment.topLeft),
                    ),
                    Align(
                        child: Text(Texta,
                            style: TextStyle(
                              fontSize: 18,
                            )),
                        alignment: Alignment.topLeft),
                  ],
                ),
              ))),
    );
  }
}
