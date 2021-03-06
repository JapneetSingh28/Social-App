import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_networking/models/user.dart';
import 'package:social_networking/pages/StoryArchives.dart';
import 'package:social_networking/pages/chatting.dart';
import 'package:social_networking/pages/home.dart';
import 'package:social_networking/pages/job_listing.dart';
import 'package:social_networking/pages/search.dart';
import 'package:social_networking/pages/testHome.dart';
import 'package:social_networking/pages/view_profile.dart';

import 'package:social_networking/pages/story.dart';
import 'package:social_networking/src/pages/index.dart';
import 'package:social_networking/widgets/avator.dart';
import 'package:social_networking/widgets/header.dart';
import 'package:social_networking/widgets/post.dart';
import 'package:social_networking/widgets/progress.dart';

import 'msgpage.dart';

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
    getFollowing();
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
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
                            style: TextStyle(fontSize: 10, fontFamily: "karla"),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: avatar ??
                          ListTile(
                            title: Text(""),
                          ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Divider(
            height: 10,
          ),
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                children: posts ??
                    ListTile(
                      title: Text(""),
                    ),
              ),
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
          color: Colors.white,
          child: ListView(
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
                        fontFamily: "karla",
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
//      appBar: header1(context, isAppTitle: true,),
      appBar: AppBar(
        title: Image.asset(
          "assets/images/precisely_logo.png",
          height: 40.0,
          width: 40.0,
        ),
        iconTheme: new IconThemeData(color: Color(0xff8B8B8B)),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: <Widget>[
//          IconButton(icon: Icon(Icons.search,size: 35.0,), onPressed: (){}),
          IconButton(
            icon: Image.asset("assets/images/msgicon.png"),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return MessagePage();
              }));
            },
          )
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      ),
      drawer: buildDrawer(),
    );
  }

  Drawer buildDrawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 40.0,
                  backgroundColor: Colors.grey,
                  backgroundImage:
                      CachedNetworkImageProvider(currentUser.photoUrl),
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  children: <Widget>[
                    Text(
                      currentUser.username,
                      style: TextStyle(
                          fontFamily: "karla",
                          color: Theme.of(context).primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${followingList.length} Connections",
                      style: TextStyle(
                          fontFamily: "karla",
                          color: Colors.grey,
                          fontSize: 16),
                    ),
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                  return ViewProfile(
                    profileId: currentUser.id,
                  );
                }));
              },
              child: Text(
                "View Profile",
                style: TextStyle(
                    fontFamily: "karla",
                    color: Theme.of(context).primaryColor,
                    fontSize: 16.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Divider(
              thickness: 2,
            ),
          ),
//          Padding(
//            padding: const EdgeInsets.symmetric(horizontal: 18.0),
//            child: Divider(
//              thickness: 2,
//            ),
//          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Status(
                              profileId: currentUser.id,
                              currentUser: currentUser,
                            )));
              },
              child: Text(
                "Status",
                style: TextStyle(
                    color: Colors.deepPurple,
                    fontFamily: "karla",
                    fontSize: 15.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Divider(
              thickness: 2,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => storyArchives(
                            profileId: currentUser.id,
                          )));
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Story Archives",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 15.0,
                    fontFamily: "karla"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Divider(
              thickness: 2,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => IndexPage()));
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Video Call",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 15.0,
                    fontFamily: "karla"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Divider(
              thickness: 2,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext c) {
                return TestHome();
              }));
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Self Evaluation",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 15.0,
                    fontFamily: "karla"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Divider(
              thickness: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MessagePage())),
              child: Text(
                "Settings & Privacy",
                style: TextStyle(
                    fontFamily: "karla",
                    color: Theme.of(context).primaryColor,
                    fontSize: 15.0),
              ),
            ),
          ),
//          Padding(
//            padding: const EdgeInsets.symmetric(horizontal: 18.0),
//            child: Divider(
//              thickness: 2,
//            ),
//          ),
//          Padding(
//            padding: const EdgeInsets.all(10.0),
//            child: Text(
//              "Groups",
//              style: TextStyle(fontSize: 15.0),
//            ),
//          ),
//          Padding(
//            padding: const EdgeInsets.symmetric(horizontal: 18.0),
//            child: Divider(
//              thickness: 2,
//            ),
//          ),
//          Padding(
//            padding: const EdgeInsets.all(10.0),
//            child: Text(
//              "Events",
//              style: TextStyle(fontSize: 15.0),
//            ),
//          ),
//          Padding(
//            padding: const EdgeInsets.only(left: 40.0),
//            child: Text(
//              "+ Add event",
//              style: TextStyle(
//                  color: Theme.of(context).primaryColor, fontSize: 15.0),
//            ),
//          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Divider(
              thickness: 2,
            ),
          ),
//          Padding(
//            padding: const EdgeInsets.all(10.0),
//            child: InkWell(
////              onTap: () => Navigator.push(context,
////                  MaterialPageRoute(builder: (context) => ChattingScreen())),
//              child: Text(
//                "Settings & Privacy",
//                style: TextStyle(fontFamily: "karla", fontSize: 15.0),
//              ),
//            ),
//          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Hashtags",
              style: TextStyle(fontFamily: "karla", fontSize: 15.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: InkWell(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MessagePage())),
              child: Text(
                "#india",
                style: TextStyle(
                    fontFamily: "karla",
                    color: Theme.of(context).primaryColor,
                    fontSize: 15.0),
              ),
            ),
          ),
//          Padding(
//            padding: const EdgeInsets.only(left: 40.0),
//            child: InkWell(
//              onTap: () => Navigator.push(context,
//                  MaterialPageRoute(builder: (context) => MessagePage())),
//              child: Text(
//                "#india",
//                style: TextStyle(
//                    fontFamily: "karla",
//                    color: Theme.of(context).primaryColor,
//                    fontSize: 15.0),
//              ),
//            ),
//          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Divider(
              thickness: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
              onTap: logout,
              child: Text(
                "Logout",
                style: TextStyle(
                    fontFamily: "karla",
                    color: Theme.of(context).primaryColor,
                    fontSize: 15.0),
              ),
            ),
          )
        ],
      ),
    );
  }
}
