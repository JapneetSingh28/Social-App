import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_networking/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:story_view/story_view.dart';

class StoryPageView extends StatefulWidget {
  final String profileId;

  StoryPageView({this.profileId});

  @override
  _StoryPageViewState createState() => _StoryPageViewState();
}

class _StoryPageViewState extends State<StoryPageView> {
  List<DocumentSnapshot> storyList;
  final controller = StoryController();
  Firestore firestore = Firestore.instance;
  final List<StoryItem> storyItems = [];

  Widget view(BuildContext context) {
    return StoryView(
      storyItems: storyItems,
      controller: controller,
      inline: false,
      repeat: false,
    );
  }

  addingToList(DocumentSnapshot document) {
    if (document["mediaType"] == "CAPTURED" ||
        document["mediaType"] == "GALLERY") {
      storyItems.add(StoryItem.pageImage(
        url: "${document["mediaUrl"]}",
        controller: controller,
        caption: document["description"],
      ));
    } else if (document["mediaType"] == "TEXT") {
      Color background;
      if (document['backgroundColor'] == "green")
        background = Colors.green;
      else if (document['backgroundColor'] == "blue")
        background = Colors.blue;
      else if (document['backgroundColor'] == "red")
        background = Colors.red;
      else if (document['backgroundColor'] == "deepPurple")
        background = Colors.deepPurple;
      else if (document['backgroundColor'] == "pinkAccent")
        background = Colors.pinkAccent;
      else if (document['backgroundColor'] == "grey") background = Colors.grey;

      storyItems.add(StoryItem.text(
          title: "${document["mediaUrl"]}",
          backgroundColor: background,
          roundedTop: true,
          roundedBottom: true));
    }
  }
  @override
  void dispose() {
    storyList?.clear();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: firestore
          .collection('posts')
          .document('${widget.profileId}')
          .collection('userStories')
          .orderBy('timestamp', descending: false)
          ?.snapshots(),
      builder: (context, snapshot) {
        storyList = snapshot?.data?.documents;
//        storyList.toSet();
        if (snapshot.hasData) {
          for (int i = 0; i < storyList.length; i++) {
            addingToList(snapshot.data.documents[i]);
          }
          return view(context);
        } else {
          return Container();
        }
      },
    );
  }
}
