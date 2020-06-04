import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_networking/models/user.dart';
import 'package:social_networking/pages/activity_feed.dart';
import 'package:social_networking/pages/home.dart';
import 'package:social_networking/pages/msgpage.dart';
import 'package:social_networking/pages/view_profile.dart';
import 'package:social_networking/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  int i=0;
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;
  Future<QuerySnapshot> searchResultsHashTagsFuture;

  handleSearch(String query) {
    Future<QuerySnapshot> users = usersRef
        .where("displayName", isGreaterThanOrEqualTo: query)
        .getDocuments();
    setState(() {
      searchResultsFuture = users;
    });
  }

  handleSearchHashTags(String query) {
    Future<QuerySnapshot> hashTags = hashTagsRef
        .where("hashTags", arrayContains: query)
        .getDocuments();
    setState(() {
      searchResultsHashTagsFuture = hashTags;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  AppBar buildSearchField() {
    return i==0?AppBar(
      title: Image.asset("assets/images/precisely_logo.png",height: 40.0,width: 40.0,),
      iconTheme: new IconThemeData(color: Color(0xff8B8B8B)),
      centerTitle: true,
      backgroundColor: Colors.white,
      actions: <Widget>[
        IconButton(icon: Icon(Icons.search,size: 35.0,), onPressed: (){setState(() {
          i=1;
        });}),
        IconButton(icon: Image.asset("assets/images/msgicon.png"),onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
            return MessagePage();
          }));
        },)
      ],):AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search for a user...",
          //  filled: true,
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
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
            padding: const EdgeInsets.only(left:17.0,top: 15.0),
            child: Text("Invitations(2)",
              style: TextStyle(fontFamily: "karla",
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0),),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right:8.0),
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
                                image: DecorationImage(image: AssetImage("assets/images/person1.jpg"),
                                    fit: BoxFit.fill),
                                shape: BoxShape.circle
                            ),
                          ),
                          Text("Rachel Zane",
                            style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: "karla"
                            ),),
                          Text("Software Engineer",
                            style: TextStyle(
                                fontSize: 12.0,
                                color: Color(0xff8B8B8B),
                                fontFamily: "karla"
                            ),),
                          Text("8 mutual",
                            style: TextStyle(
                                fontSize: 10.0,
                                color: Color(0xff8B8B8B),
                                fontFamily: "karla"
                            ),)
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
                              image: DecorationImage(image: AssetImage("assets/images/person2.jpg"),
                                  fit: BoxFit.fill),
                              shape: BoxShape.circle
                          ),
                        ),
                        Text("Mike Ross",
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: "karla"
                          ),),
                        Text("Student",
                          style: TextStyle(
                              fontSize: 12.0,
                              color: Color(0xff8B8B8B),
                              fontFamily: "karla"
                          ),),
                        Text("4 mutual",
                          style: TextStyle(
                              fontSize: 10.0,
                              color: Color(0xff8B8B8B),
                              fontFamily: "karla"
                          ),)
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

  bool get wantKeepAlive => true;
  Drawer buildDrawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  child: Text("A"),
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  children: <Widget>[
                    Text(
                      "Abhishek Avi",
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "450 Connections",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
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
                Navigator.of(context)
                    .push(new MaterialPageRoute(builder: (_){
                  return ViewProfile();
                }));
              },
              child: Text(
                "View Profile",
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 16.0),
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
            child: Text(
              "Settings & Privacy",
              style: TextStyle(fontSize: 15.0),
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
            child: Text(
              "Groups",
              style: TextStyle(fontSize: 15.0),
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
            child: Text(
              "Events",
              style: TextStyle(fontSize: 15.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: Text(
              "+ Add event",
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 15.0),
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
            child: Text(
              "Hashtags",
              style: TextStyle(fontSize: 15.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: Text(
              "#india",
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 15.0),
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
            child: Text(
              "Terms & Conditions",
              style: TextStyle(fontSize: 15.0),
            ),
          )
        ],
      ),
    );


  }
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      drawer: buildDrawer(),
      backgroundColor: Colors.white,
      appBar: buildSearchField(),
      body:
      searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
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
                  backgroundColor: Colors.grey,
                  backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                ),
                title: Text(
                  user.displayName,
                  style:
                  TextStyle( fontWeight: FontWeight.bold,
                      fontFamily: "karla"),
                ),
                subtitle: Text(
                  user.username,
                  style: TextStyle(
                      fontFamily: "karla"
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
