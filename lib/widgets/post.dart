import 'dart:async';
import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:social_networking/models/user.dart';
import 'package:social_networking/pages/activity_feed.dart';
import 'package:social_networking/pages/comments.dart';
import 'package:social_networking/pages/home.dart';
import 'package:social_networking/widgets/custom_image.dart';
import 'package:social_networking/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class Post extends StatefulWidget {
  final String hashName;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;
  final Timestamp timestamp;


  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
      timestamp: doc['timestamp'],
      hashName: doc['hashName'],
    );
  }

  int getLikeCount(likes) {
    // if no likes, return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    // if the key is explicitly set to true, add a like
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        location: this.location,
        description: this.description,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
        timestamp: this.timestamp,
        hashName: this.hashName,
      );
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final Timestamp timestamp;
  final String hashName;
  bool showHeart = false;
  bool isLiked;
  int likeCount;
  Map likes;

 

  int noComments = 0;

  countComments() async {
    QuerySnapshot snapshot = await commentsRef
        .document(postId)
        .collection('comments')
        .getDocuments();
    if (this.mounted)
      setState(() {
        noComments = snapshot.documents.length;
//    print(noComments);
      });
  }

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        bool isPostOwner = currentUserId == ownerId;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
            radius: 23.0,
          ),
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: Text(
              user.username[0].toUpperCase() +
                  user.username.substring(1).toLowerCase(),
              style: TextStyle(
                color: Colors.black,
                fontFamily: "karla",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(
            user.bio ?? "Developer",
            style: TextStyle(
                fontFamily: "karla", fontSize: 14.0, color: Color(0xff8B8B8B)),
          ),
          trailing: isPostOwner
              ? IconButton(
                  onPressed: () => handleDeletePost(context),
                  icon: Icon(Icons.more_vert),
                )
              : Text(
                  timeago.format(timestamp.toDate()),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: "karla",
                      fontSize: 14.0,
                      color: Color(0xff8B8B8B)),
                ),
        );
      },
    );
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Remove this post?"),
            children: <Widget>[
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    deletePost();
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  )),
              SimpleDialogOption(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel')),
            ],
          );
        });
  }

  // Note: To delete post, ownerId and currentUserId must be equal, so they can be used interchangeably
  deletePost() async {
    // delete post itself
    postsRef
        .document(ownerId)
        .collection('userPosts')
        .document(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  
    // then delete all comments
    QuerySnapshot commentsSnapshot = await commentsRef
        .document(postId)
        .collection('comments')
        .getDocuments();
    commentsSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleLikePost() async {
    if (hashName == null || hashName == "") {
      print("User: $username , $hashName");
      bool _isLiked = likes[currentUserId] == true;

      if (_isLiked) {
        postsRef
            .document(ownerId)
            .collection('userPosts')
            .document(postId)
            .updateData({'likes.$currentUserId': false});
        removeLikeFromActivityFeed();
        setState(() {
          likeCount -= 1;
          isLiked = false;
          likes[currentUserId] = false;
        });
      } else if (!_isLiked) {
        postsRef
 
        });
      }
    } else {
      print("User: $username , $hashName");
      bool _isLiked = likes[currentUserId] == true;

      if (_isLiked) {
        postsRef
            .document(ownerId)
            .collection('userPosts')
            .document(postId)
            .updateData({'likes.$currentUserId': false});
        postsRef
            .document(hashName)
            .collection('userPosts')
            .document(postId)
            .updateData({'likes.$currentUserId': false});
        removeLikeFromActivityFeed();
        setState(() {
          likeCount -= 1;
          isLiked = false;
          likes[currentUserId] = false;
        });
      } else if (!_isLiked) {
        postsRef
            .document(ownerId)
            .collection('userPosts')
            .document(postId)
            .updateData({'likes.$currentUserId': true});
        addLikeToActivityFeed();
        setState(() {
          likeCount += 1;
          isLiked = true;
          likes[currentUserId] = true;
          showHeart = true;
        });
        postsRef
      

  addLikeToActivityFeed() {
    // add a notification to the postOwner's activity feed only if comment made by OTHER user (to avoid getting notification for our own like)
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoUrl,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
         ly: "karla", fontSize: 14.0),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Align(
                    alignment: Alignment.bottomRight,
                    heightFactor: 0.45,
                    widthFactor: 0.97,
                    child: cachedNetworkImage(mediaUrl)),
              ),
            ],
          ),
//          cachedNetworkImage(mediaUrl),
          showHeart
              ? Animator(
                  duration: Duration(milliseconds: 300),
                
                    child: Icon(
                      Icons.thumb_up,
                      size: 80.0,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                )
              : Text(""),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: CircleAvatar(
                        backgroundColor: Color(0xff6D00D9),
                        radius: 13.5,
                        child: Center(
            
//                      radius: 13.5,
//                      child: Center(child: Image.asset("assets/images/clap.png",
//                        height: 20.0,
//                        width: 20.0,))),
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Text(
                      "$likeCount",
                      style: TextStyle(
                          color: Color(0xff8B8B8B),
                          fontFamily: "karla",
                          fontSize: 14.0),
                    ),
                  ),
                ],
              ),
              Text(
                "$noComments comments",
                style: TextStyle(
                    fontSize: 14.0,
                    color: Color(0xff8B8B8B),
                    fontFamily: "karla"),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Divider(
            color: Color(0xffBDBDBD),
            thickness: 0.2,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FlatButton.icon(
                onPressed: handleLikePost,
                icon: Icon(
                  Icons.thumb_up,
                  color: isLiked ? Color(0xff6D00D9) : Color(0xff8B8B8B),
                ),
                label: Text(
                  "Like",
                  style:
                      TextStyle(fontFamily: "karla", color: Color(0xff8B8B8B)),
                )),
            FlatButton.icon(
                onPressed: () => showComments(
                      context,
                      postId: postId,
                      ownerId: ownerId,
                      mediaUrl: mediaUrl,
                    ),
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: Color(0xff8B8B8B),
                ),
                label: Text(
                  "Comment",
                  style:
                      TextStyle(fontFamily: "karla", color: Color(0xff8B8B8B)),
                )),
            FlatButton.icon(
                onPressed: () {},
                icon: Icon(
                  Icons.share,
                  color: Color(0xff8B8B8B),
                ),
                label: Text(
                  "Share",
                  style:
                      TextStyle(fontFamily: "karla", color: Color(0xff8B8B8B)),
                ))
          ],
        ),
//        Row(
//          mainAxisAlignment: MainAxisAlignment.start,
//          children: <Widget>[
//            Padding(padding: EdgeInsets.only(left: 20.0)),
//            GestureDetector(
//              onTap: handleLikePost,
//              child: Icon(
//                isLiked ? Icons.favorite : Icons.favorite_border,
//                size: 28.0,
//                color: Colors.pink,
//              ),
//            ),
//            Padding(padding: EdgeInsets.only(right: 20.0)),
//            GestureDetector(
//              onTap: () => showComments(
//                context,
//                postId: postId,
//                ownerId: ownerId,
//                mediaUrl: mediaUrl,
//              ),
//              child: Icon(
//                Icons.chat,
//                size: 28.0,
//                color: Colors.blue[900],
//              ),
//            ),
//          ],
//        ),
//        Row(
//          children: <Widget>[
//            Container(
//              margin: EdgeInsets.only(left: 20.0),
//              child: Text(
//                "$likeCount likes",
//                style: TextStyle(
//                  color: Colors.black,
//                  fontWeight: FontWeight.bold,
//                ),
//              ),
//            ),
//          ],
//        ),
//        Row(
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: <Widget>[
//            Container(
//              margin: EdgeInsets.only(left: 20.0),
//              child: Text(
//                "$username ",
//                style: TextStyle(
//                  color: Colors.black,
//                  fontWeight: FontWeight.bold,
//                ),
//              ),
//            ),
//            Expanded(child: Text(description))
//          ],
//        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    countComments();
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
        Divider(
          height: 20,
        )
      ],
    );
  }
}

showComments(BuildContext context,
    {String postId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}
