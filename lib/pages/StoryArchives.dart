import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_networking/widgets/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
     return Container(
       height: 208.5,
       width: 138.75,
       decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(10.0),
           image: DecorationImage(
               image: NetworkImage(
                   "${document["mediaUrl"]}"),
               fit: BoxFit.fill)),
     );
   }else{
     return Container(
       height: 208.5,
       width: 138.75,
         child: Center(child: Text("${document["mediaUrl"]}",style: TextStyle(color: Colors.white),),),
       decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(10.0),
         color: col,
       ),
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
