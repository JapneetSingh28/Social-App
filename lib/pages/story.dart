import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_networking/models/user.dart';
import 'package:social_networking/pages/home.dart';
import 'package:social_networking/pages/textStoryScreen.dart';
import 'package:social_networking/widgets/progress.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as Im;
import 'StoryPageView.dart';



class Status extends StatefulWidget {
  final String profileId;
  final User currentUser;

  Status({this.profileId,this.currentUser});

  @override
  _StatusState createState() => _StatusState();
}

class _StatusState extends State<Status>
    with AutomaticKeepAliveClientMixin<Status> {

  File file;
  TextEditingController captionController = TextEditingController();
  bool isUploading = false;
  String storyId = Uuid().v4();
  String mediaType = "";
  Firestore firestore = Firestore.instance;
  List<DocumentSnapshot> userFollowing = [];


//  getFollowers() async {
//    QuerySnapshot snapshot = await followersRef
//        .document(widget.profileId)
//        .collection('userFollowers')
//        .getDocuments();
//    setState(() {
//      userFollowing = snapshot.documents;
//    });
//    return userFollowing;
//  }

  sendStory(){
    return FutureBuilder(
      future: usersRef.document(widget?.profileId).get(),
      builder: (context,snapshot){
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Container(
          color: Color(0xfff2f2f2),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Card(
                color: Colors.white,
                elevation: 0.0,
                child: ListTile(
                  leading: Stack(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 25.0,
                        backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                      ),
                      Positioned(
                        bottom: 0.0,
                        right: 1.0,
                        child: Container(
                          height: 20.0,
                          width: 20.0,
                          child: Icon(Icons.add,color: Colors.white,size: 15,),
                          decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text("My Status",style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),),
                  subtitle: Text("Tap to add status update") ,
                  onTap: (){
                    selectImage(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Recent Updates",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey ),),
              ),
              Card(
                color: Colors.white,
                elevation: 0.0,
                child: ListTile(
                  leading: Stack(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 25.0,
                        backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                      ),
                    ],
                  ),
                  title: Text("My Status",style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),),
                  subtitle: Text("${timestamp.toString().substring(0,11)}") ,
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => StoryPageView(profileId: widget.currentUser?.id,)
                    ));
                  },
                ),
              ),

//              Expanded(
//                child: StreamBuilder(
//                  stream: firestore.collection('stories')
//                      .document('${widget.currentUser?.id}')
//                      .collection('userFollowing')
//                      .snapshots(),
//                  builder: (context,snapshot){
//                  getFollowers();
//                  for(int i=0;i<)
//                  },
//                ),
//              )

            ],
          ),
        );
      },
    );
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: clearImage),
        title: Text(
  
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(file),
              
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
              CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Write a caption...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
    storageRef.child("post_$storyId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createStoryInFirestore(
      
      "timestamp": timestamp,
      "mediaType" : mediaType,
      "backgroundColor" : "",
      "profileUrl": widget.currentUser.photoUrl
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$storyId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  selectImage(parentContext)  {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Create Post"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Photo with Camera"), onPressed: handleTakePhoto),
            SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: handleChooseFromGallery),
            SimpleDialogOption(
                child: Text("Text Story"),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => textStoryScreen(currentUser: widget.currentUser,mediaType: mediaType,)
                  ));
                  setState(() {
                    this.mediaType = "TEXT";
                  });
                }
            )
          ],
        );
      },
    );
  }

  handleTakePhoto() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
      this.mediaType = "CAPTURED";
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
      this.mediaType = "GALLERY";
    });
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Status",style: TextStyle(color: Colors.deepPurple),),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.deepPurple),
      ),
      body: file == null ? sendStory() : buildUploadForm(),
    );
  }
}