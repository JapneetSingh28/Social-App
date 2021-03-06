import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_networking/models/user.dart';
import 'package:social_networking/pages/StoryArchives.dart';
import 'package:social_networking/pages/activity_feed.dart';
import 'package:social_networking/pages/hashTagPage.dart';
import 'package:social_networking/pages/home.dart';
import 'package:social_networking/pages/msgpage.dart';
import 'package:social_networking/pages/story.dart';
import 'package:social_networking/pages/testHome.dart';
import 'package:social_networking/pages/view_profile.dart';
import 'package:social_networking/src/pages/index.dart';
import 'package:social_networking/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState
    extends State<Search> //    with AutomaticKeepAliveClientMixin<Search>
{
  int i = 0;
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;
  Future<QuerySnapshot> searchResultsHashTagsFuture;
  bool isEmpty = true;
  bool isHashSearch = false;
  List<String> followingList = [];

  handleSearch(String query) {
    Future<QuerySnapshot> users = usersRef
        .where("displayName", isGreaterThanOrEqualTo: query)
        .getDocuments();
    setState(() {
      searchResultsFuture = users;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(currentUser?.id)
        .collection('userFollowing')
        .getDocuments();
    if (this.mounted)
      setState(() {
        followingList =
            snapshot.documents.map((doc) => doc.documentID).toList();
      });
  }

  buildUsersToFollow() {
    return StreamBuilder(
      stream:
          usersRef.orderBy('timestamp', descending: true).limit(5).snapshots(),
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

  handleSearchHashTags(String query) {
    Future<QuerySnapshot> hashTags =
        hashTagsRef.where("hashName", isEqualTo: query).getDocuments();
    setState(() {
      searchResultsHashTagsFuture = hashTags;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  searchOrHash() {
    String strList = searchController.text;
    List strg = strList.split(' ');
    if (strList.isEmpty || strList == null) {
      setState(() {
        isEmpty = true;
      });
    }
    strg.forEach((f) {
      bool hash = f.startsWith('#');
      if (hash) {
        handleSearchHashTags(f);
//        hashTagsSearched.add(f.toString().substring(1));
//        hashTagsSearched.forEach((h) {
//          handleSearchHashTags(f);
//        });
        setState(() {
          isEmpty = false;
          isHashSearch = true;
        });
      } else if (f.toString().isNotEmpty) {
        handleSearch(f);
        setState(() {
          isEmpty = false;
          isHashSearch = false;
        });
      } else {
        setState(() {
          isEmpty = true;
        });
      }
    });
  }

  AppBar buildSearchField() {
    return i == 0
        ? AppBar(
            title: Image.asset(
              "assets/images/precisely_logo.png",
              height: 40.0,
              width: 40.0,
            ),
            iconTheme: new IconThemeData(color: Color(0xff8B8B8B)),
            centerTitle: true,
            backgroundColor: Colors.white,
            actions: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.search,
                    size: 35.0,
                  ),
                  onPressed: () {
                    setState(() {
                      i = 1;
                    });
                  }),
//              IconButton(
//                icon: Image.asset("assets/images/msgicon.png"),
//                onPressed: () {
//                  Navigator.of(context)
//                      .push(MaterialPageRoute(builder: (BuildContext context) {
//                    return MessagePage();
//                  }));
//                },
//              )
            ],
          )
        : AppBar(
            iconTheme: IconThemeData(color: Color(0xff8B8B8B)),
            backgroundColor: Colors.white,
            title: TextFormField(
              autofocus: true,
              style: TextStyle(fontFamily: "karla"),
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search for a user...",
                //  filled: true,
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: clearSearch,
                ),
              ),
              onFieldSubmitted: searchOrHash(),
            ),
          );
  }

  Container buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 17.0, top: 15.0),
            child: Text(
              "Invitations(2)",
              style: TextStyle(
                  fontFamily: "karla",
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Card(
                    elevation: 4.5,
                    child: Container(
                      height: 161.0,
                      width: 150.0,
                      color: Color(0xff00000029),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: 54.0,
                            width: 54.0,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image:
                                        AssetImage("assets/images/person1.jpg"),
                                    fit: BoxFit.fill),
                                shape: BoxShape.circle),
                          ),
                          Text(
                            "Rachel Zane",
                            style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: "karla"),
                          ),
                          Text(
                            "Software Engineer",
                            style: TextStyle(
                                fontSize: 12.0,
                                color: Color(0xff8B8B8B),
                                fontFamily: "karla"),
                          ),
                          Text(
                            "8 mutual",
                            style: TextStyle(
                                fontSize: 10.0,
                                color: Color(0xff8B8B8B),
                                fontFamily: "karla"),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 40.0, right: 10.0),
                                  child: CircleAvatar(
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    ),
                                    radius: 15.0,
                                    backgroundColor: Color(0xff6D00D9),
                                  ),
                                ),
                                Container(
                                  height: 30.0,
                                  width: 30.0,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Color(0xff8B8B8B),
                                          width: 1.0)),
                                  child: Center(
                                      child: Icon(
                                    Icons.clear,
                                    color: Color(0xff8B8B8B),
                                  )),
                                  //backgroundColor: Color(0xff6D00D9),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Card(
                  elevation: 4.5,
                  child: Container(
                    height: 161.0,
                    width: 150.0,
                    color: Color(0xff00000029),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 54.0,
                          width: 54.0,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image:
                                      AssetImage("assets/images/person2.jpg"),
                                  fit: BoxFit.fill),
                              shape: BoxShape.circle),
                        ),
                        Text(
                          "Mike Ross",
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: "karla"),
                        ),
                        Text(
                          "Student",
                          style: TextStyle(
                              fontSize: 12.0,
                              color: Color(0xff8B8B8B),
                              fontFamily: "karla"),
                        ),
                        Text(
                          "4 mutual",
                          style: TextStyle(
                              fontSize: 10.0,
                              color: Color(0xff8B8B8B),
                              fontFamily: "karla"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 40.0, right: 10.0),
                                child: CircleAvatar(
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                                  radius: 15.0,
                                  backgroundColor: Color(0xff6D00D9),
                                ),
                              ),
                              Container(
                                height: 30.0,
                                width: 30.0,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Color(0xff8B8B8B), width: 1.0)),
                                child: Center(
                                    child: Icon(
                                  Icons.clear,
                                  color: Color(0xff8B8B8B),
                                )),
                                //backgroundColor: Color(0xff6D00D9),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
//    return Container(
//      child: Center(
//        child: ListView(
//          shrinkWrap: true,
//          children: <Widget>[
//            SvgPicture.asset(
//              'assets/images/search.svg',
//              height: orientation == Orientation.portrait ? 300.0 : 200.0,
//            ),
//            Text(
//              "Find Users",
//              textAlign: TextAlign.center,
//              style: TextStyle(
//                color: Colors.white,
//                fontStyle: FontStyle.italic,
//                fontWeight: FontWeight.w600,
//                fontSize: 60.0,
//              ),
//            ),
//          ],
//        ),
//      ),
//    );
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        });
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  Map<dynamic, dynamic> dataHash = {};

//  gettingHashPosts() async {
//    final DocumentSnapshot result = await hashTagsRef
//        .document(searchController.text.substring(1)).get();
////        .collection('hashtagsposts')
////        .getDocuments();
////    final
////    final List<DocumentSnapshot> documents = result.;
////    documents.forEach((data) => dataHash.addAll({data.documentID: data.data}));
//    result.exists?dataHash.addAll({result.documentID: result.data}):print("object no found");
//    print(dataHash);
//  }

  buildSearchHashTagsResults() {
//    gettingHashPosts();
//    bool hashExists = false;
//    hashTagsRef.document(searchController.text).get().then((onValue){
//      onValue.exists ? hashExists=true :hashExists=false,
//    });
//    Navigator.push(context, MaterialPageRoute(
//        builder: (context) => HashTagPage(searchController.text)));
    return Card(
      elevation: 4.5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HashTagPage(searchController.text))),
          title: Text(
            '${searchController.text}',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontFamily: "karla",
            ),
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          leading: CircleAvatar(
            radius: 25,
            child: Text('#'),
          ),
        ),
      ),
    );

//    return FutureBuilder(
//      future: searchResultsFuture,
//      builder: (context, snapshot) {
//        if (!snapshot.hasData) {
//          return circularProgress();
//        }
//        gettingHashPosts();
//        List<UserResult> searchResults = [];
//        snapshot.data.documents.forEach((doc) {
//          User user = User.fromDocument(doc);
//          UserResult searchResult = UserResult(user);
//          searchResults.add(searchResult);
//        });
//        return ListView(
//          children: searchResults,
//        );
//      },
//    );
  }

//  bool get wantKeepAlive => true;

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Divider(
              thickness: 2,
            ),
          ),
//          Padding(
//            padding: const EdgeInsets.all(10.0),
//            child: InkWell(
//              onTap: () => Navigator.push(context,
//                  MaterialPageRoute(builder: (context) => MessagePage())),
//              child: Text(
//                "Terms & Conditions",
//                style: TextStyle(
//                    fontFamily: "karla",
//                    color: Theme.of(context).primaryColor,
//                    fontSize: 15.0),
//              ),
//            ),
//          ),
//          Padding(
//            padding: const EdgeInsets.symmetric(horizontal: 18.0),
//            child: Divider(
//              thickness: 2,
//            ),
//          ),
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

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  void dispose() {
    searchController?.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getFollowing();
  }

  @override
  Widget build(BuildContext context) {
//    super.build(context);

    return Scaffold(
      drawer: buildDrawer(),
      backgroundColor: Colors.white,
      appBar: buildSearchField(),
//      body: searchResultsFuture == null
//          ? searchResultsHashTagsFuture == null
//              ? buildNoContent()
//              : buildSearchHashTagsResults()
//          : buildSearchResults(),
      body: isEmpty
          ? buildUsersToFollow()
          : isHashSearch && searchResultsHashTagsFuture != null
              ? buildSearchHashTagsResults()
              : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.5,
      child: Container(
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () => showProfile(context, profileId: user.id),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                  backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                ),
                title: Text(
                  user.displayName ?? "User",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontFamily: "karla"),
                ),
                subtitle: Text(
                  user?.username ?? "Developer",
                  style: TextStyle(fontFamily: "karla"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
