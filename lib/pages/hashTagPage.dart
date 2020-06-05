import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  gridItem(BuildContext context, DocumentSnapshot document) {
    return GestureDetector(
      onTap: () => showPosts(context,
          ownerId: document['ownerId'], postId: document['postId']),
      child: GridTile(
        child: cachedNetworkImage(document['mediaUrl']),
      ),
    );
  }

  showPosts(BuildContext context, {String postId, String ownerId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: postId,
          userId: ownerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: widget.hashName),
      body: StreamBuilder(
        stream: hashTagsRef
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
          print(snapshot.data.documents.length);
          return GridView.builder(
              itemCount: snapshot.data.documents.length,
              scrollDirection: Axis.vertical,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio:0.7,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                    child: gridItem(context, snapshot.data.documents[index]));
              });
        },
      ),
    );
  }
}
