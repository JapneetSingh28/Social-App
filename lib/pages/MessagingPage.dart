import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_networking/pages/home.dart';
import 'package:social_networking/widgets/header.dart';
import 'package:social_networking/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

class MessagingPage extends StatefulWidget {
  final String profileId;
  final String profilename;

  MessagingPage({
    this.profileId,
    this.profilename,
  });

  @override
  _MessagingPageState createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  String chatRoomId = '';
  TextEditingController messageController = TextEditingController();
  String messageId = Uuid().v4();

  @override
  void initState() {
//    chatRoomId = "${currentUser.id}+${widget.profileId}";
//    messagingRef.document(chatRoomId).setData({});
//    print(chatRoomId);
    checkChatRoom();
    super.initState();
  }

  checkChatRoom() async {
    chatRoomId = "${widget.profileId}+${currentUser.id}";
    print(chatRoomId);
    DocumentSnapshot doc = await messagingRef.document(chatRoomId).get();
    print(doc.data);
    print(doc.documentID);
    if (!doc.exists) {
      print("doc not existed");
      setState(() {
        chatRoomId = "${currentUser.id}+${widget.profileId}";
        messagingRef.document(chatRoomId).setData({});
        print(chatRoomId);
      });
    }
  }

  addMessage() {
    final DateTime timestampChat = DateTime.now();
    print(timestampChat);
    messagingRef
        .document(chatRoomId)
        .collection("chats")
        .document(messageId)
        .setData({
      "message": messageController.text.trim(),
      "timestamp": timestampChat,
      "ownerId": currentUser.id,
    }, merge: true);
    messageId = Uuid().v4();

//    bool isNotPostOwner = postOwnerId != currentUser.id;
//    if (isNotPostOwner) {
//      activityFeedRef.document(postOwnerId).collection('feedItems').add({
//        "type": "comment",
//        "commentData": commentController.text,
//        "timestamp": timestamp,
//        "postId": postId,
//        "userId": currentUser.id,
//        "username": currentUser.username,
//        "userProfileImg": currentUser.photoUrl,
//        "mediaUrl": postMediaUrl,
//      });
//    }
    messageController.clear();
  }

  buildMessages() {
    return StreamBuilder(
        stream: messagingRef
            .document(chatRoomId)
            .collection('chats')
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<Message> messages = [];
          snapshot.data.documents.forEach((doc) {
            messages.add(Message.fromDocument(doc));
          });
          return ListView(
            reverse: true,
            children: messages,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: widget.profilename),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildMessages(),
          ),
          Divider(),
          Align(
            alignment: Alignment.bottomCenter,
            child: ListTile(
              title: TextFormField(
                controller: messageController,
                decoration: InputDecoration(labelText: "Write a comment..."),
              ),
              trailing: OutlineButton(
                onPressed: addMessage,
                borderSide: BorderSide.none,
                child: Icon(Icons.send),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Message extends StatelessWidget {
  final String ownerId;
  final String message;
  final Timestamp timestamp;

  Message({
    this.ownerId,
    this.message,
    this.timestamp,
  });

  factory Message.fromDocument(DocumentSnapshot doc) {
    return Message(
      ownerId: doc['ownerId'],
      message: doc['message'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isOwner = currentUser.id == ownerId;
    return Container(
      width: MediaQuery.of(context).size.width/2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: isOwner ?MainAxisAlignment.end:MainAxisAlignment.start,
        crossAxisAlignment: isOwner ?CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              elevation: 5.0,
              child: Padding(
                padding: const EdgeInsets.only(left:8.0,bottom: 7.0,right: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: isOwner ?MainAxisAlignment.end:MainAxisAlignment.start,
                  crossAxisAlignment: isOwner ?CrossAxisAlignment.end:CrossAxisAlignment.start,
                  children: <Widget>[
                    isOwner ? Text("") : Text(message),
                    isOwner ? Text(message) : Text(""),
                    Text(
                      timeago.format(timestamp.toDate()),
                      textAlign: isOwner ? TextAlign.left : TextAlign.right,
                      style: TextStyle(color: Colors.grey,fontStyle: FontStyle.italic,fontSize:12.0),
                    ),
//              ListTile(
//                leading: isOwner ? Text("") : Text(message),
//                trailing: isOwner ? Text(message) : Text(""),
//
////          title: Text(message),
//                subtitle: Text(
//                  timeago.format(timestamp.toDate()),
//                  textAlign: isOwner ? TextAlign.left : TextAlign.right,
//                ),
//              ),
//          Divider(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
