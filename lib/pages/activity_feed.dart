import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_networking/pages/home.dart';
import 'package:social_networking/pages/post_screen.dart';
import 'package:social_networking/pages/profile.dart';
import 'package:social_networking/pages/view_profile.dart';
import 'package:social_networking/widgets/header.dart';
import 'package:social_networking/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .document(currentUser.id)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .getDocuments();
    List<ActivityFeedItem> feedItems = [];
    snapshot.documents.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));
      // print('Activity Feed Item: ${doc.data}');
    });
    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset("assets/images/precisely_logo.png",height: 40.0,width: 40.0,),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
          child: FutureBuilder(
        future: getActivityFeed(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          return ListView(
            children: snapshot.data,
          );
        },
      )),
    );
  }
}

Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type; // 'like', 'follow', 'comment'
  final String mediaUrl;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final Timestamp timestamp;

  ActivityFeedItem({
    this.username,
    this.userId,
    this.type,
    this.mediaUrl,
    this.postId,
    this.userProfileImg,
    this.commentData,
    this.timestamp,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc['username'],
      userId: doc['userId'],
      type: doc['type'],
      postId: doc['postId'],
      userProfileImg: doc['userProfileImg'],
      commentData: doc['commentData'],
      timestamp: doc['timestamp'],
      mediaUrl: doc['mediaUrl'],
    );
  }

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: postId,
          userId: userId,
        ),
      ),
    );
  }

  configureMediaPreview(context) {
    if (type == "like" || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(mediaUrl),
                  ),
                ),
              )),
        ),
      );
    } else {
      mediaPreview = Text('');
    }

    if (type == 'like') {
      activityItemText = "liked your post";
    } else if (type == 'follow') {
      activityItemText = "is following you";
    } else if (type == 'comment') {
      activityItemText = 'replied: $commentData';
    } else {
      activityItemText = "Error: Unknown type '$type'";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);

    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Container(
        color: Colors.white54,
        child: Card(
          elevation: 4.5,
          color: Colors.grey.shade200,
          child: ListTile(
            title: GestureDetector(
              onTap: () => showProfile(context, profileId: userId),
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: "karla",
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: username,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                        color: Color(0xff6D00D9)),
                      ),
                      TextSpan(
                        text: ' $activityItemText',
                      ),
                    ]),
              ),
            ),
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userProfileImg),
            ),
            subtitle: Text(
              timeago.format(timestamp.toDate()),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: "karla"),
            ),
            trailing: mediaPreview,
          ),
        ),
      ),
    );
  }
}

showProfile(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ViewProfile(
        profileId: profileId,
      ),
    ),
  );
}
