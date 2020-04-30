import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TabActivity extends StatelessWidget{
  String n = "";
  TabActivity({Key key, this.n}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.red[500],
      title: "TabActivity",
      home: DefaultTabController(
        length: 2,
        child: TabScreen(n: n,),
      ),
    );
  }
}

class TabScreen extends StatefulWidget{
  String n = "";
  TabScreen({Key key, this.n}) : super(key: key);
  @override
  State createState() => TabScreenState();
}

class TabScreenState extends State<TabScreen>{
  final TextEditingController textController = new TextEditingController();
  List<message> messageList = [];
  bool isActive = false;

  Widget buildMessageBox(){
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: Row(
          children: <Widget>[
            Expanded(
              child:TextField(
                  controller: textController,
                  onSubmitted: sendSubmit,
                  onChanged: (String text){
                    setState(() {
                      if(text.isEmpty){
                        isActive = false;
                      }else{
                        isActive = true;
                      }
                    });
                  },
                  decoration: new InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(15),
                        )
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellow, width: 1),
                    ),
                    filled: true,
                    hintText: "Type...",
                    fillColor: Colors.white,
                  )
              ),
            ),
            Container(
              child: IconButton(
                color: isActive ? Colors.red : Colors.green,
                icon: Icon(Icons.send),
                onPressed: () => sendSubmit(textController.text),
              ),
            ),
          ],
        )
    );
  }

  void sendSubmit(String text){
    textController.clear();
    message m = new message(
      name: widget.n,
      text: text,
    );
    setState(() {
      messageList.insert(0, m);
    });
  }

  void saveMessages() async {
    List<String> saveMessageList = new List();
    for(message m in messageList){
      saveMessageList.insert(0, m.text);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('flutterBasic', saveMessageList);
  }

  void loadMessages() async {
    if(messageList.isNotEmpty){
      setState(() {
        messageList.clear();
      });
    }
    List<String> loadMessageList = new List();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loadMessageList = prefs.getStringList('flutterBasic');

    for(String i in loadMessageList){
      message m = new message(
        name: widget.n,
        text: i,
      );

      setState(() {
        messageList.add(m);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.green,
        title: Text("Testing"),
        actions: <Widget>[
          // action button
          IconButton(
              icon: Icon(Icons.file_upload),
              color: Colors.red,
              onPressed: () => saveMessages()
          ),
          // action button
          IconButton(
              icon: Icon(Icons.file_download),
              color: Colors.red,
              onPressed: () => loadMessages()
          ),
        ],
        bottom: TabBar(
          labelColor: Colors.red,
          unselectedLabelColor: Colors.green,
          tabs: <Widget>[
            Tab(text: "HTTP",),
            Tab(text: "Chat")
          ],
        ),
      ),
      body: TabBarView(
          children: [
            Container(
              child: FutureBuilder<List<Contact>>(
                future: fetchPosts(http.Client()),
                builder: (context, snapshot) {
                  if (snapshot.hasError) print(snapshot.error);

                  return snapshot.hasData
                      ? ListContact(contactList: snapshot.data)
                      : Center(
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
                        backgroundColor: Colors.green,
                      ));
                },
              ),
            ),
            Container(
                child: Column(
                  children: <Widget>[
                    Flexible(
                      child: ListView.builder(
                        padding: EdgeInsets.all(8),
                        reverse: true,
                        itemBuilder: (_, int index) => messageList[index],
                        itemCount: messageList.length,
                      ),
                    ),
                    Container(
                      child: buildMessageBox(),
                    )
                  ],
                )
            )
          ]
      ),
    );
  }
}

class message extends StatelessWidget{
  message({this.name,this.text});
  final String text;
  final String name;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment:  CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: new CircleAvatar(
              backgroundColor: Colors.red,
              child: new Text(
                name[0],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(name, style: Theme.of(context).textTheme.subtitle2),
              Container(
                margin: const EdgeInsets.only(top: 5),
                child: Text(text),
              )
            ],
          )
        ],
      ),
    );
  }
}

class Contact {
  final String gender;
  final String first;
  final String last;

  Contact({this.first, this.last, this.gender});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      first: json['First'] as String,
      last: json['Last'] as String,
      gender: json['Gender'] as String,
    );
  }
}

List<Contact> parsePosts(String responseBody) {
  print(responseBody);
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Contact>((json) => Contact.fromJson(json)).toList();
}

Future<List<Contact>> fetchPosts(http.Client client) async {
  final response = await client.get('https://your-own-url');
  return compute(parsePosts, response.body);
}

class ListContact extends StatelessWidget {
  final List<Contact> contactList;

  ListContact({Key key, this.contactList}) : super(key: key);

  String g = "UnIdentified";

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
          itemCount: contactList.length,
          padding: const EdgeInsets.all(15.0),
          itemBuilder: (context, position) {
            if(contactList[position].gender.contains("1")){
              g = "Male";
            }else{
              g = "Female";
            }
            return Column(
              children: <Widget>[
                Divider(height: 5.0),
                ListTile(
                  title: Text(contactList[position].first + contactList[position].last,
                    style: TextStyle(
                      fontSize: 22.0,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: Text("Gender:" + g,
                    style: new TextStyle(
                      color: Colors.green,
                      fontSize: 18.0,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  leading: Column(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.green[200],
                        radius: 15.0,
                        child: Text(contactList[position].first[0],
                          style: TextStyle(
                            color: Colors.red[800],
                          ),
                        ),
                      )
                    ],
                  ),
                  onTap: () => _onTapItem(context, contactList[position]),
                ),
              ],
            );
          }),
    );
  }

  void _onTapItem(BuildContext context, Contact contact) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Person Information"),
      content: Text(contact.first + " " + contact.last +
          " " + " is a " + g),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}