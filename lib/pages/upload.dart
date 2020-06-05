import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_networking/models/user.dart';
import 'package:social_networking/pages/home.dart';
import 'package:social_networking/widgets/progress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  List<String> hashTags = [];
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  File file;
  bool isUploading = false;
  String postId = Uuid().v4();
  Future<QuerySnapshot> searchResultsHashTagsFuture;

  handleTakePhoto() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }

  selectImage(parentContext) {
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
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  Scaffold buildSplashScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          "assets/images/precisely_logo.png", height: 40.0, width: 40.0,),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset('assets/images/upload.svg', height: 260.0),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    "Upload Image",
                    style: TextStyle(
                      fontFamily: "karla",
                      color: Colors.white,
                      fontSize: 22.0,
                    ),
                  ),
                  color: Color(0xff6D00D9),
                  onPressed: () => selectImage(context)),
            ),
          ],
        ),
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
    storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      {String mediaUrl, String location, String description}) {
    postsRef
        .document(widget.currentUser.id)
        .collection("userPosts")
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {},
    });
  }

  handleSearchHashTagsInPosts(String query) {
    Future<QuerySnapshot> hashTags =
    hashTagsRef.where("hashName", isEqualTo: query).getDocuments();
    setState(() {
      searchResultsHashTagsFuture = hashTags;
    });
  }

  createPostWithHashTagsInFirestore (
      {String mediaUrl, String location, String description}) async {
    final QuerySnapshot result =
        await hashTagsRef.getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
//    List alreadyHash=[];
    Map<dynamic,dynamic> dataHash = {};
//    documents.forEach((data) => alreadyHash.add(data.data));

    documents.forEach((data) => dataHash.addAll({data.documentID:data.data}));
    print(dataHash);
    print("object");

    hashTags.forEach((hash) {
      List<Map> dataHashall = dataHash[hash]['postDetails'];
//      dataHashall.forEach((M){
//
//      });
      print(hash);
      print("object");
//     if(alreadyHash.contains(hash)){
////       hashTagsRef.document(hash).updateData((data){
////
////       });
//
//     }else{
//
//     }
     hashTagsRef.document(hash).get().then((onValue){
       onValue.exists ?  hashTagsRef.document(hash).updateData({
//         "hashName": hash,
           "postDetails": [
//             dataHash[hash]['postDetails'],
             {
             "postId": postId,
             "ownerId": widget.currentUser.id,
             "username": widget.currentUser.username,
             "mediaUrl": mediaUrl,
             "description": description,
             "location": location,
             "timestamp": timestamp,
             "likes": {}
             }
           ],
       })
       :
         hashTagsRef.document(hash).setData({
           "hashName": hash,
           "postDetails": [{
             "postId": postId,
             "ownerId": widget.currentUser.id,
             "username": widget.currentUser.username,
             "mediaUrl": mediaUrl,
             "description": description,
             "location": location,
             "timestamp": timestamp,
             "likes": {}
           }
           ],
           "timestamp": timestamp,
           "followers": [],
         });
     });
    });
  }

  handleSubmit() async {
    String strList = captionController.text;
    List strg = strList.split(' ');
    strg.forEach((f) {
      bool hash = f.startsWith('#');
      if (hash) {
        f.replaceAll('#', '');
        hashTags.add(f.toString().substring(1));
      }
      print(hashTags);
    });
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    await createPostWithHashTagsInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: clearImage),
        centerTitle: true,
        title: Image.asset(
          "assets/images/precisely_logo.png", height: 40.0, width: 40.0,),
        actions: [
          FlatButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: Text(
              "Post",
              style: TextStyle(
                color: Color(0xff6D00D9),
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          Container(
            height: 220.0,
            width: MediaQuery
                .of(context)
                .size
                .width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(file),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
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
                  hintStyle: TextStyle(fontFamily: "karla"),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Color(0xff6D00D9),
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Where was this photo taken?",
                  hintStyle: TextStyle(fontFamily: "karla"),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              label: Text(
                "Use Current Location",
                style: TextStyle(color: Colors.white,
                    fontFamily: "karla"),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Color(0xff6D00D9),
              onPressed: getUserLocation,
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress =
        '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark
        .subLocality} ${placemark.locality}, ${placemark
        .subAdministrativeArea}, ${placemark.administrativeArea} ${placemark
        .postalCode}, ${placemark.country}';
    print(completeAddress);
    String formattedAddress = "${placemark.locality}, ${placemark.country}";
    locationController.text = formattedAddress;
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
