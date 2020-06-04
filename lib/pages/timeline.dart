import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_networking/models/user.dart';
import 'package:social_networking/pages/home.dart';
import 'package:social_networking/pages/search.dart';
import 'package:social_networking/pages/story.dart';
import 'package:social_networking/widgets/avator.dart';
import 'package:social_networking/widgets/header.dart';
import 'package:social_networking/widgets/post.dart';
import 'package:social_networking/widgets/progress.dart';

final usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;
  List<AvatarData> avatar;
  Future<QuerySnapshot> searchResultsFuture;
  List<DocumentSnapshot> followersFuture;
  List<String> followingList = [];

  @override
  void initState() {
    super.initState();
    getTimeline();
    getTimelineStory();
    getFollowing();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .document(widget.currentUser?.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Post> posts =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  getTimelineStory() async {
    QuerySnapshot snapshot = await timelineRef
        .document(widget.currentUser?.id)
        .collection('timelineStories')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<AvatarData> avatar =
        snapshot.documents.map((doc) => AvatarData.fromDocument(doc)).toList();
    setState(() {
      this.avatar = avatar;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(currentUser?.id)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingList = snapshot.documents.map((doc) => doc.documentID).toList();
    });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildUsersToFollow();
    } else {
      return Container(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
//                height: 75,
//                width: MediaQuery.of(context).size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Status(
                                      profileId: currentUser.id,
                                      currentUser: currentUser,
                                    )));
                      },
                      child: Column(
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                                currentUser.photoUrl),
                            backgroundColor: Colors.grey,
                            radius: 30,
                          ),
                          Text(
                            currentUser.displayName,
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: avatar,
                    )
                  ],
                ),
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ListView(children: posts),
            ),
          ),
        ],
      ));
    }
  }

//  buildTimelineStories() {
//    if (avatar == null) {
//      return  GestureDetector(
//        onTap: () {
//          Navigator.push(
//              context,
//              MaterialPageRoute(
//                  builder: (context) => Status(
//                    profileId: currentUser.id,
//                    currentUser: currentUser,
//                  )));
//        },
//        child: Column(
//          children: <Widget>[
//            CircleAvatar(
//              backgroundImage:
//              CachedNetworkImageProvider(currentUser.photoUrl),
//              backgroundColor: Colors.grey,
//              radius: 30,
//            ),
//            Text(
//              currentUser.displayName,
//              style: TextStyle(fontSize: 10),
//            ),
//          ],
//        ),
//      );
//    } else if (posts.isEmpty) {
//      return  GestureDetector(
//        onTap: () {
//          Navigator.push(
//              context,
//              MaterialPageRoute(
//                  builder: (context) => Status(
//                    profileId: currentUser.id,
//                    currentUser: currentUser,
//                  )));
//        },
//        child: Column(
//          children: <Widget>[
//            CircleAvatar(
//              backgroundImage:
//              CachedNetworkImageProvider(currentUser.photoUrl),
//              backgroundColor: Colors.grey,
//              radius: 30,
//            ),
//            Text(
//              currentUser.displayName,
//              style: TextStyle(fontSize: 10),
//            ),
//          ],
//        ),
//      );
//    } else {
//      return Container(
//          child: Column(
//            children: <Widget>[
//              Padding(
//                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
//                child: Container(
//                  child: Row(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    mainAxisAlignment: MainAxisAlignment.start,
//                    children: <Widget>[
//                      GestureDetector(
//                        onTap: () {
//                          Navigator.push(
//                              context,
//                              MaterialPageRoute(
//                                  builder: (context) => Status(
//                                    profileId: currentUser.id,
//                                    currentUser: currentUser,
//                                  )));
//                        },
//                        child: Column(
//                          children: <Widget>[
//                            CircleAvatar(
//                              backgroundImage:
//                              CachedNetworkImageProvider(currentUser.photoUrl),
//                              backgroundColor: Colors.grey,
//                              radius: 30,
//                            ),
//                            Text(
//                              currentUser.displayName,
//                              style: TextStyle(fontSize: 10),
//                            ),
//                          ],
//                        ),
//                      ),
//                  Row(
//                    children: avatar ,
//                  )
//                    ],
//                  ),
//                ),
//              ),
//              Divider(),
//            ],
//          ));
//    }
//  }

  buildUsersToFollow() {
    return StreamBuilder(
      stream:
          usersRef.orderBy('timestamp', descending: true).limit(30).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> userResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          final bool isAuthUser = currentUser.id == user.id;
          final bool isFollowingUser = followingList.contains(user.id);
          // remove auth user from recommended list
          if (isAuthUser) {
            return;
          } else if (isFollowingUser) {
            return;
          } else {
            UserResult userResult = UserResult(user);
            userResults.add(userResult);
          }
        });
        return Container(
          color: Theme.of(context).accentColor.withOpacity(0.2),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.person_add,
                      color: Theme.of(context).primaryColor,
                      size: 30.0,
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      "Users to Follow",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 30.0,
                      ),
                    ),
                  ],
                ),
              ),
              Column(children: userResults),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
        appBar: header(context, isAppTitle: true),
        body: RefreshIndicator(
            onRefresh: () => getTimeline(),
            child: buildTimeline()));
  }
}
