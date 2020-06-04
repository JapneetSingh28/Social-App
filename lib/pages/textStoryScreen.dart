import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_networking/models/user.dart';
import 'package:uuid/uuid.dart';

import 'home.dart';

class textStoryScreen extends StatefulWidget {
  final User currentUser;
  final String mediaType;

  textStoryScreen({this.currentUser, this.mediaType});

  @override
  _textStoryScreenState createState() => _textStoryScreenState();
}

class _textStoryScreenState extends State<textStoryScreen> {
  Color containerColor = Colors.red;
  TextEditingController controller = TextEditingController();
  String storyId = Uuid().v4();
  String color = "red";

  storyScreen() {
    return Scaffold(
      body: Container(
        color: containerColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  elevation: 0.0,
                  color: containerColor,
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: controller,
                    maxLines: null,
                    autofocus: true,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30.0,
                    ),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: "Type Here",
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          postsRef
              .document(widget.currentUser.id)
              .collection("userStories")
              .document(storyId)
              .setData({
            "storyId": storyId,
            "ownerId": widget.currentUser.id,
            "username": widget.currentUser.username,
            "mediaUrl": controller.text,
            "timestamp": timestamp,
            "mediaType": widget.mediaType,
            "backgroundColor": color,
            "description": "",
            "profileUrl": widget.currentUser.photoUrl
          });
          Navigator.pop(context);
        },
        tooltip: "Post",
        child: Icon(Icons.send),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          height: MediaQuery.of(context).size.height / 12,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text("Choose Color"),
              Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        containerColor = Colors.green;
                        color = "green";
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 12.0),
                      child: Container(
                        width: 25.0,
                        height: 25.0,
                        decoration: BoxDecoration(
                            color: Colors.green, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        containerColor = Colors.blue;
                        color = 'blue';
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 12.0),
                      child: Container(
                        width: 25.0,
                        height: 25.0,
                        decoration: BoxDecoration(
                            color: Colors.blue, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        containerColor = Colors.red;
                        color = "red";
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 12.0),
                      child: Container(
                        width: 25.0,
                        height: 25.0,
                        decoration: BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        containerColor = Colors.deepPurple;
                        color = "deepPurple";
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 12.0),
                      child: Container(
                        width: 25.0,
                        height: 25.0,
                        decoration: BoxDecoration(
                            color: Colors.deepPurple, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        containerColor = Colors.pinkAccent;
                        color = "pinkAccent";
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 12.0),
                      child: Container(
                        width: 25.0,
                        height: 25.0,
                        decoration: BoxDecoration(
                            color: Colors.pinkAccent, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        containerColor = Colors.grey;
                        color = "grey";
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 12.0),
                      child: Container(
                        width: 25.0,
                        height: 25.0,
                        decoration: BoxDecoration(
                            color: Colors.grey, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return storyScreen();
  }
}
