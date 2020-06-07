import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_networking/pages/home.dart';
import 'package:social_networking/pages/post_screen.dart';
import 'package:social_networking/widgets/header.dart';
import 'package:social_networking/widgets/progress.dart';

class HashTagPage extends StatefulWidget {
  final String hashName;

  HashTagPage(this.hashName);

  @override
  _HashTagPageState createState() => _HashTagPageState();
}

class _HashTagPageState extends State<HashTagPage> {
  bool hasHashData = true;
  bool isFollowing = false;
  int postCount = 0;
  int followerCount = 0;

  Widget cachedNetworkImage(String mediaUrl) {
    return CachedNetworkImage(
      imageUrl: mediaUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Padding(
        child: CircularProgressIndicator(),
        padding: EdgeInsets.all(20.0),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }

//  containsHashOrNot(){
//    if(this.mounted){
//     setState(() {
////       hashTagsRef
////           .document(widget.hashName.substring(1)).get().then((onValue){
////         onValue.exists ? noHashData=false : noHashData=true ;
////       });
//       hashTagsRef
//           .document(widget.hashName.substring(1))
//           .collection('hashtagposts')
//           .getDocuments().then((onValue){
//             print("This${onValue.documents.length}");
//             (onValue.documents.length==0)? noHashData=true: noHashData=false;
//       });
////       builder: (context, snapshot) {
////       if (!snapshot.hasData) {
////       return Center(
////       child: circularProgress(),
////       );
//     });
//    }
////    print(snapshot.data.documents.length);
////    if(this.mounted)setState(() {
////    (snapshot.data.documents.
////
////    });
//  }


 

  checkIfHashExists() async {
//    DocumentSnapshot doc =
//        await hashTagsRef.document(widget.hashName.substring(1)).get();
//    setState(() {
//      hasHashData = doc.exists;
//      print('This is ${doc.data.length}');
//    });
    hashTagsRef
        .document(widget.hashName.substring(1))
        .collection('hashtagposts')
  
    });
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .document(widget.hashName.substring(1))
        .collection('userFollowers')
        .document(currentUser.id)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 215.0,
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
     
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    // remove follower
    followersRef
        .document(widget.hashName.substring(1))
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
        .document(widget.hashName.substring(1))
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
//    // delete activity feed item for them
//    activityFeedRef
//        .document(currentUser.id)
//        .collection('feedItems')
//        .document(currentUser.id)
//        .get()
//        .then((doc) {
//      if (doc.exists) {
//        doc.reference.delete();
//      }
//    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    // Make auth user follower of THAT user (update THEIR followers collection)
    followersRef
   
        .setData({});
//    // add activity feed item for that user to notify about new follower (us)
//    activityFeedRef
//        .document(widget.profileId)
//        .collection('feedItems')
//        .document(currentUserId)
//        .setData({
//      "type": "follow",
//      "ownerId": widget.profileId,
//      "username": currentUser.username,
//      "userId": currentUserId,
//      "userProfileImg": currentUser.photoUrl,
//      "timestamp": timestamp,
//    });
  }

  buildProfileButton() {
    // viewing your own profile - should show edit profile button
    if (isFollowing) {
      return buildButton(
        text: "Unfollow",
        function: handleUnfollowUser,
      );
    } else if (!isFollowing) {
      return buildButton(
        text: "Follow",
        function: handleFollowUser,
      );
    }
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .document(widget.hashName.substring(1))
        .collection('userFollowers')
        .getDocuments();
    setState(() {
      followerCount = snapshot.documents.length;
    });
  }

  @override
  void initState() {
    super.initState();
    checkIfHashExists();
    checkIfFollowing();
    getFollowers();
    checkIfFollowing();
  }


//  @override
//  void initState() {
//    super.initState();
//    if(this.mounted)setState(() {
//      hashTagsRef
//           .document(widget.hashName.substring(1)).get().then((onValue){
//         onValue.exists ? noHashData=false : noHashData=true ;
//       });
////      hashTagsRef
////          .document(widget.hashName.substring(1))
////          .collection('hashtagposts')
////          .getDocuments().then((onValue){
////        print("This${onValue.documents.length}");
////        (onValue.documents.length==0)? noHashData=true: noHashData=false;
////      });
//    });
////    containsHashOrNot();
//  }

  @override
  Widget build(BuildContext context) {
//      containsHashOrNot();
    print(hasHashData);
    return Scaffold(
      appBar: header(context, titleText: widget.hashName),
      body: hasHashData
          ? Container(
              child: Column(
                children: <Widget>[
                  Container(height: 15,),
                  Row(
            
                          .document(widget.hashName.substring(1))
                          .collection('hashtagposts')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: circularProgress(),
                          );
                        }
                        return GridView.builder(
                            itemCount: snapshot.data.documents.length,
                            scrollDirection: Axis.vertical,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 0.7,
                                    crossAxisSpacing: 5.0,
                                    mainAxisSpacing: 5.0),
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: gridItem(
                                      context, snapshot.data.documents[index]));
                            });
                      },
                    ),
                  ),
                ],
              ),
            )
          : Container(
              alignment: Alignment.center,
              child: Column(
           
                    height: 200,
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
            ),
    );
  }
}
