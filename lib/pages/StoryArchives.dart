import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_networking/widgets/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home.dart';

class storyArchives extends StatefulWidget {

  final String profileId;

  storyArchives({this.profileId});


  @override
  _storyArchivesState createState() => _storyArchivesState();
}

class _storyArchivesState extends State<storyArchives> {

  Firestore firestore = Firestore.instance;
  List stories = [];
  Color col = Colors.red;

  createAlertDialogforImage(BuildContext context, String storyId,String username,String mediaUrl,String description){
    return showDialog(context: context,builder: (context){
      return SimpleDialog(
        title: Text("Choose from Options"),
        children: <Widget>[
          Divider(height: 20.0,),
          SimpleDialogOption(
              child: Text("Delete this Story"),onPressed: (){
            Firestore.instance.collection('posts')
                .document('${widget.profileId}')
                .collection('userStories')
                .document('$storyId').delete();
            Navigator.pop(context);
          },),
          Divider(height: 20.0,),
          SimpleDialogOption(
              child: Text("Post this Story"),onPressed: (){
            postsRef
                .document(widget.profileId)
                .collection("userPosts")
                .document(storyId)
                .setData({
              "postId": storyId,
              "ownerId": widget.profileId,
              "username": username,
              "mediaUrl": mediaUrl,
              "description": description,
              "location": "",
              "timestamp": timestamp,
              "likes": {},
            });
            Navigator.pop(context);
          },),
          Divider(height: 20.0,),
          SimpleDialogOption(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      );
    });
  }

  createAlertDialogforText(BuildContext context,String storyId){
    return showDialog(context: context,builder: (context){
      return SimpleDialog(
        title: Text("Choose from Options\n(Note: you can't post Text stories)"),
        children: <Widget>[
          Divider(height: 20.0,),
          SimpleDialogOption(
            child: Text("Delete this Story"),onPressed: (){
              Firestore.instance.collection('posts')
                  .document('${widget.profileId}')
                  .collection('userStories')
                  .document('$storyId').delete();
              Navigator.pop(context);
          },),
          Divider(height: 20.0,),
          SimpleDialogOption(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      );
    });
  }

  Widget GridItem(BuildContext context, DocumentSnapshot document){

   if(document["mediaType"] == "TEXT"){
     if(document["backgroundColor"] == "red")
       col = Colors.red;
     else if(document["backgroundColor"] == "blue")
       col = Colors.blue;
     else if(document["backgroundColor"] == "green")
       col = Colors.green;
     else if(document["backgroundColor"] == "pinkAccent")
       col = Colors.pinkAccent;
     else if(document["backgroundColor"] == "grey")
       col = Colors.grey;
   }

   if(document["mediaType"] == "GALLERY" || document["mediaType"] == "CAPTURED"){
     return Stack(
       children: <Widget>[
         Container(
           height: 208.5,
           width: 138.75,
           decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(10.0),
               image: DecorationImage(
                   image: NetworkImage(
                       "${document["mediaUrl"]}"),
                   fit: BoxFit.fill)),
         ),
         Row(
           mainAxisAlignment: MainAxisAlignment.end,
           children: <Widget>[
             GestureDetector(
               onTap: (){
                 createAlertDialogforImage(context,document["storyId"].toString(),
                     document["username"],document["mediaUrl"],document["description"]);
               },
               child: Container(
                 width: 40.0,
                 height: 40.0,
                 child: Icon(Icons.more_vert),
                 decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(5.0),
                   color: Colors.grey.withOpacity(0.5),
                 ),
               ),
             ),
           ],
         ),
       ],
     );
   }else{
     return Stack(
       children: <Widget>[
         Container(
           height: 208.5,
           width: 138.75,
           child: Center(child: Text("${document["mediaUrl"]}",style: TextStyle(color: Colors.white),),),
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(10.0),
             color: col,
           ),
         ),
         Row(
          mainAxisAlignment: MainAxisAlignment.end,
           children: <Widget>[
             GestureDetector(
               onTap: (){
                 createAlertDialogforText(context,document["storyId"].toString());
               },
               child: Container(
                 width: 40.0,
                 height: 40.0,
                 child: Icon(Icons.more_vert),
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(5.0),
                   color: Colors.grey.withOpacity(0.5),
                 ),
               ),
             ),
           ],
         ),
       ],
     );
   }
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,titleText: "Story Archives"),
      body: StreamBuilder(
        stream: firestore
            .collection('posts')
            .document('${widget.profileId}')
            .collection('userStories')
            .orderBy('timestamp', descending: false)
            ?.snapshots(),
        builder: (context,snapshot){
          if(!snapshot.hasData){
            return Center(child: Text("LoAdInG EvEnTs....."),);
               }
          return GridView.builder(
              itemCount: snapshot.data.documents.length,
              scrollDirection: Axis.vertical,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,childAspectRatio: MediaQuery.of(context).size.width /
                  (MediaQuery.of(context).size.height),crossAxisSpacing: 5.0, mainAxisSpacing: 5.0
              ),
              itemBuilder: (context,index){
                return GridItem(context,snapshot.data.documents[index]);
              }
          );
        },
      ),
    );
  }
}
