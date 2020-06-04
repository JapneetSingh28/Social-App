import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_networking/pages/StoryPageView.dart';
import 'package:social_networking/pages/home.dart';

class AvatarData extends StatefulWidget {
  final String storyId;
  final String ownerId;
  final String username;
  final String mediaType;
  final String description;
  final String mediaUrl;
  final String backgroundColor;
  final String profileUrl;

  AvatarData({
    this.storyId,
    this.ownerId,
    this.username,
    this.mediaType,
    this.description,
    this.mediaUrl,
    this.backgroundColor,
    this.profileUrl,
  });

  factory AvatarData.fromDocument(DocumentSnapshot doc) {
    return AvatarData(
        storyId: doc['storyId'],
        ownerId: doc['ownerId'],
        username: doc['username'],
        mediaUrl: doc['mediaUrl'],
        mediaType: doc['mediaType'],
        description: doc['description'],
        backgroundColor: doc['backgroundColor'],
        profileUrl: doc['profileUrl'],
    );
  }

  @override
  _AvatarDataState createState() =>
      _AvatarDataState(
        storyId: this.storyId,
        ownerId: this.ownerId,
        username: this.username,
        mediaUrl: this.mediaUrl,
        mediaType: this.mediaType,
        description: this.description,
        backgroundColor: this.backgroundColor,
        profileUrl: this.profileUrl,
      );
}

class _AvatarDataState extends State<AvatarData> {
  final String currentUserId = currentUser?.id;
  final String storyId;
  final String ownerId;
  final String username;
  final String mediaType;
  final String description;
  final String mediaUrl;
  final String backgroundColor;
  final String profileUrl;

  _AvatarDataState({
    this.storyId,
    this.ownerId,
    this.username,
    this.mediaType,
    this.description,
    this.mediaUrl,
    this.backgroundColor,
    this.profileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left:12.0),
      child: Container(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StoryPageView(profileId: ownerId,)));
          },
          child: Column(
            children: <Widget>[
              CircleAvatar(
                backgroundImage:
                CachedNetworkImageProvider(profileUrl),
                backgroundColor: Colors.grey,
                radius: 30,
              ),
              Text(
                username,
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}