import 'testHome.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social_networking/models/user.dart';
import 'package:social_networking/pages/StoryArchives.dart';
import 'package:social_networking/pages/edit_profile.dart';
import 'package:social_networking/pages/home.dart';
import 'package:social_networking/pages/msgpage.dart';
import 'package:social_networking/src/pages/index.dart';
import 'package:social_networking/widgets/post.dart';
import 'package:social_networking/widgets/post_tile.dart';
import 'package:social_networking/widgets/progress.dart';

class ViewProfile extends StatefulWidget {
  final String profileId;

  ViewProfile({this.profileId});

  @override
  _ViewProfileState createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  bool isFollowing = false;
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];
  int followerCount = 0;
  int followingCount = 0;

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUser.id)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .getDocuments();
    setState(() {
      followerCount = snapshot.documents.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(widget.profileId)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingCount = snapshot.documents.length;
    });
  }

  Drawer buildDrawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
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
                            profileId: widget.profileId,
                          )));
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Story Archives",
                style: TextStyle(fontSize: 15.0, fontFamily: "karla"),
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
                style: TextStyle(fontSize: 15.0, fontFamily: "karla"),
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
                style: TextStyle(fontSize: 15.0, fontFamily: "karla"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Divider(
              thickness: 2,
            ),
          ),
        ],
      ),
    );
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .document(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/no_content.svg',
              height: 150,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "No Posts",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)
//          child: ClipRRect(
//            borderRadius: BorderRadius.all(Radius.circular(30.0)),
//            child: PostTile(post),
//          ),
            ));
      });
      return GridView.count(
        crossAxisCount: 1,
        childAspectRatio: 1.47,
        mainAxisSpacing: 10,
        crossAxisSpacing: 2,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
//        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    }
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUser.id)));
  }

  buildProfileButton() {
    // viewing your own profile - should show edit profile button
    bool isProfileOwner = currentUser.id == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        icon: Icon(
          Icons.edit,
//          color: Colors.white,
        ),
        function: editProfile,
      );
    } else if (isFollowing) {
      return buildButton(
        icon: Icon(Icons.person_add),
        function: handleUnfollowUser,
      );
    } else if (!isFollowing) {
      return buildButton(
        icon: Icon(Icons.person_add),
        function: handleFollowUser,
      );
    }
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    // remove follower
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUser.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // remove following
    followingRef
        .document(currentUser.id)
        .collection('userFollowing')
        .document(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete activity feed item for them
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUser.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    // Make auth user follower of THAT user (update THEIR followers collection)
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUser.id)
        .setData({});
    // Put THAT user on YOUR following collection (update your following collection)
    followingRef
        .document(currentUser.id)
        .collection('userFollowing')
        .document(widget.profileId)
        .setData({});
    // add activity feed item for that user to notify about new follower (us)
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUser.id)
        .setData({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": currentUser.username,
      "userId": currentUser.id,
      "userProfileImg": currentUser.photoUrl,
      "timestamp": timestamp,
    });
  }

  Container buildButton({Icon icon, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: IconButton(
        color: isFollowing ? Colors.white : Theme.of(context).primaryColor,
        onPressed: function,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isProfileOwner = currentUser.id == widget.profileId;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.deepPurple,
      ),
//      endDrawer: isProfileOwner?buildDrawer():Container(),
      body: SingleChildScrollView(
        child: FutureBuilder(
            future: usersRef.document(widget.profileId).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              }
              User user = User.fromDocument(snapshot.data);
              return Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(40.0),
                                bottomRight: Radius.circular(40.0),
                              ),
                              color: Theme.of(context).primaryColor),
                          width: double.infinity,
                          height: 250,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15.0, left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
//                                      IconButton(
//                                        color: Colors.white,
//                                        onPressed: () => print("object"),
//                                        icon: Icon(Icons.menu),
//                                        tooltip: "swipe left to open drawer",
//                                      ),
                                    ],
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 40.0,
                                  backgroundColor: Colors.grey,
                                  backgroundImage:
                                      CachedNetworkImageProvider(user.photoUrl),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    user.username ??
                                        user.displayName[0].toUpperCase() +
                                            user.displayName.substring(1),
                                    style: TextStyle(
                                        fontFamily: "karla",
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                                Text(
                                  user.bio ?? "Developer",
                                  style: TextStyle(
                                      fontFamily: "karla",
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "India",
                                        style: TextStyle(
                                            fontFamily: "karla",
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom: 2,
                        child: GestureDetector(
//                          onTap: () => Navigator.push(
//                              context,
//                              MaterialPageRoute(
//                                  builder: (context) => EditProfile(
//                                      currentUserId: currentUser.id))),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                isFollowing ? Colors.blue : Colors.grey[200],
//                      child: Icon(
//                        Icons.edit,
//                        color: Theme.of(context).primaryColor,
//                      ),
                            child: buildProfileButton(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Hi there! I am ${user.username ?? user.displayName[0].toUpperCase() + user.displayName.substring(1)} , currently working as "
                      "${user.bio ?? "Developer"}.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: "karla", fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MessagePage())),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.asset(
                              "assets/images/resume.png",
                              height: 200.0,
//                              width: 40.0,
                            ),
                          ),
                          Icon(
                            Icons.play_arrow,
                            size: 70,
                            color: Colors.grey.withOpacity(.8),
                          ),
                        ],
                      ),
//                      Container(
//                        alignment: Alignment.center,
//                        width: double.infinity,
//                        height: 150,
//                        decoration: BoxDecoration(
//                            borderRadius: BorderRadius.all(
//                              Radius.circular(20.0),
//                            ),
//                            color: Colors.grey),
//                        child: Column(
//                          crossAxisAlignment: CrossAxisAlignment.center,
//                          mainAxisAlignment: MainAxisAlignment.center,
//                          children: <Widget>[
//                            Image.asset(
//                              "assets/images/resume.png",
////                              height: 40.0,
////                              width: 40.0,
//                            ),
//                          ],
//                        ),
//                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Experience",
                          style: TextStyle(fontFamily: "karla", fontSize: 16),
                        ),
                        Icon(
                          Icons.edit,
                          color: Theme.of(context).primaryColor,
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        height: 120,
                        width: 120,
                        child: Card(
                          elevation: 5.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 20,
                                child: Image.asset("assets/icons/adobe.png"),
                                backgroundColor: Colors.white,
                              ),
                              Text(
                                "Adobe",
                                style: TextStyle(
                                    fontFamily: "karla",
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "UI/UX Designer",
                                style: TextStyle(
                                    fontFamily: "karla",
                                    fontSize: 14,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        height: 120,
                        width: 120,
                        child: Card(
                          elevation: 5.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 20,
                                child: Image.asset("assets/icons/linkedin.png"),
                                backgroundColor: Colors.white,
                              ),
                              Text(
                                "LinkedIn",
                                style: TextStyle(
                                    fontFamily: "karla",
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Lead Designer",
                                style: TextStyle(
                                    fontFamily: "karla",
                                    fontSize: 14,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        height: 120,
                        width: 120,
                        child: Card(
                          elevation: 5.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 20,
                                child: Image.asset("assets/icons/fb.png"),
                                backgroundColor: Colors.white,
                              ),
                              Text(
                                "Facebook",
                                style: TextStyle(
                                    fontFamily: "karla",
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Intern",
                                style: TextStyle(
                                    fontFamily: "karla",
                                    fontSize: 14,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Articles & Activity",
                          style: TextStyle(fontFamily: "karla", fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height / 3,
                    width: MediaQuery.of(context).size.width - 10,
                    child: buildProfilePosts(),
                  ),
                  Container(
                    height: 20,
                  ),
                ],
              );
            }),
      ),
    );
  }
}
