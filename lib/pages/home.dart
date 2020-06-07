import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:social_networking/models/user.dart';
import 'package:social_networking/pages/activity_feed.dart';
import 'package:social_networking/pages/create_account.dart';
import 'package:social_networking/pages/job_home.dart';
import 'package:social_networking/pages/job_listing.dart';
import 'package:social_networking/pages/profile.dart';
import 'package:social_networking/pages/search.dart';
import 'package:social_networking/pages/timeline.dart';
import 'package:social_networking/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final hashTagsRef = Firestore.instance.collection('hashtags');
final commentsRef = Firestore.instance.collection('comments');
final activityFeedRef = Firestore.instance.collection('feed');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');
final timelineRef = Firestore.instance.collection('timeline');
final DateTime timestamp = DateTime.now();
User currentUser;
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
String email;
String password;
bool _autoValidate = false;
int index=0;
bool obscureyext=true;
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isWaiting = false ;
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      await createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      // 3) get username from create account, use it to make new user document in users collection
      usersRef.document(user.id).setData({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp
      });

      doc = await usersRef.document(user.id).get();
    }

    currentUser = User.fromDocument(doc);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      index=pageIndex;
    });
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(currentUser: currentUser),
          Search(),
          Upload(currentUser: currentUser),
          ActivityFeed(),
          JobHome(currentUser: currentUser),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: onTap,
          activeColor: Theme.of(context).primaryColor,
          items: [
            BottomNavigationBarItem(icon: Image.asset("assets/images/bottom1.png",
            fit: BoxFit.scaleDown,
            height: 30.0,
            width: 30.0,
            color: index==0?Color(0xff6D00D9):Color(0xff8B8B8B),)),
            BottomNavigationBarItem(icon: Image.asset("assets/images/bottom2.png",
            fit: BoxFit.scaleDown,
            height: 30.0,
            width: 30.0,
            color: index==1?Color(0xff6D00D9):Color(0xff8B8B8B),)),
            BottomNavigationBarItem(
              icon:  Icon(
                Icons.add_circle,
                size: 45.0,
                color: Color(0xff6D00D9),
              ),
            ),
            BottomNavigationBarItem(icon: Image.asset("assets/images/bottom3.png",
            color: index==3?Color(0xff6D00D9):Color(0xff8B8B8B),
            fit: BoxFit.scaleDown,
            height: 30.0,
            width: 30.0,)),
            BottomNavigationBarItem(icon: Image.asset("assets/images/bottom4.png",
            color: index==4?Color(0xff6D00D9):Color(0xff8B8B8B),
            fit: BoxFit.scaleDown,
            height: 30.0,
            width: 30.0,)),
          ]),
    );
    // return RaisedButton(
    //   child: Text('Logout'),
    //   onPressed: logout,
    // );
  }
  Scaffold buildUnAuthScreen(){
    return Scaffold(
      body: Container(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top:50.0),
              child: Image.asset("assets/images/precisely_logo.png",
              height: 80.89,
              width: 80.94,),
            ),
            Padding(
              padding: const EdgeInsets.only(top:20.0),
              child: Image.asset("assets/images/component.png",
              height: 30.0,
              width: 100.0,),
            ),
            Container(height: 10,),
            Padding(
              padding: const EdgeInsets.all(7.0),
              child: InkWell(
                onTap: () {
                  login();
                },
                child: Container(
                  height: 69.0,
                  width: 69.0,
//                  decoration: BoxDecoration(
//                      color: Colors.white,
//                      shape: BoxShape.circle,
//                      image: DecorationImage(image: AssetImage(
//                          "assets/images/google.png"),
//                          fit: BoxFit.scaleDown),
//                      border: Border.all(color: Color(0xff6D00D9),width: 1.0)
//                    //borderRadius: BorderRadius.circular(30.0),
//                  ),
                  child: Image.asset("assets/images/newgoogle.png",
//                    height: 80.89,
//                    width: 80.94,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: InkWell(
                onTap: () {
                  currentUser = User(
                    id:'102559740660975769254',
                    email: 'tempm7338@gmail.com',
                    username: 'Jaskaran',
                    photoUrl: ' https://lh3.googleusercontent.com/-2ZqfKtoAME4/AAAAAAAAAAI/AAAAAAAAAAA/AMZuucmTcfz1_oMIBZyhbPQkcUDZWwIluA/s96-c/photo.jpg',
                    displayName: 'Temp Mail',
                    bio: '',
                  );
                  setState(() {
                    isAuth=true;
                  });
                },
                child: Container(
                  height: 65.0,
                  width: 65.0,
//                  decoration: BoxDecoration(
//                      color: Colors.white,
//                      shape: BoxShape.circle,
//                      image: DecorationImage(image: AssetImage(
//                          "assets/images/linkedin.png"),
//                          fit: BoxFit.scaleDown),
//                      border: Border.all(color: Color(0xff6D00D9),width: 1.0)
//                    //borderRadius: BorderRadius.circular(30.0),
//                  ),
                child: Image.asset("assets/images/newdeveloper.png",
//                  height: 65,
//                  width: 65,
                ),
                ),
              ),
            ),
////           Container(
////             child: Column(
////               mainAxisAlignment: MainAxisAlignment.start,
////               crossAxisAlignment: CrossAxisAlignment.start,
////               children: <Widget>[
////                 Padding(
////                   padding: const EdgeInsets.only(top:50.0,left: 30.0),
////                   child: Text("Login",
////                     style: TextStyle(
////                       fontSize: 24.0,
////                       fontWeight: FontWeight.bold,
////                     fontFamily: "karla"),),
////                 ),
////                 Padding(
////                   padding: const EdgeInsets.only(top:30.0,left: 30.0),
////                   child: Text("Email",
////                     style: TextStyle(
////                         fontFamily:"karla",
////                     fontSize: 16.0,),),
////                 ),
////                 Padding(
////                   padding: const EdgeInsets.only(left:30.0,right: 30.0),
////                   child: TextField(
////                     decoration: InputDecoration(
////                       hintText: "anon@example.com",
////                       hintStyle: TextStyle(fontFamily: "karla",fontSize: 14.0,color: Color(0xffBDBDBD)),
////                     ),
////                   ),
////                 ),
////                 Padding(
////                   padding: const EdgeInsets.only(top:20.0,left: 30.0),
////                   child: Text("Password",
////                     style: TextStyle(
////                         fontFamily:"karla",
////                         fontSize: 16.0),),
////                 ),
////                 Padding(
////                   padding: const EdgeInsets.only(left:30.0,right: 30.0),
////                   child: TextField(
////                     decoration: InputDecoration(
////                         hintText: "•••••••••••••",
////                         hintStyle: TextStyle(fontFamily: "karla",fontSize: 14.0,color: Color(0xffBDBDBD)),
////                     ),
////                   ),
////                 )
////               ],
////             ),
////           ),
//            Padding(
//              padding: const EdgeInsets.only(top:30.0,left: 100.0,right: 100.0),
//              child: InkWell(
//                onTap: (){
//                  currentUser = User(
//                    id:'102559740660975769254',
//                    email: 'tempm7338@gmail.com',
//                    username: 'Jaskaran',
//                    photoUrl: ' https://lh3.googleusercontent.com/-2ZqfKtoAME4/AAAAAAAAAAI/AAAAAAAAAAA/AMZuucmTcfz1_oMIBZyhbPQkcUDZWwIluA/s96-c/photo.jpg',
//                    displayName: 'Temp Mail',
//                    bio: '',
//                  );
//                  setState(() {
//                    isAuth=true;
//                  });
//                },
//                child: Container(
//                  height: 36.0,
//                  decoration: BoxDecoration(
//                      borderRadius: BorderRadius.circular(25.0),
//                      color: Color(0xff6D00D9)
//                  ),
//                  child: Center(child: Text("Login",
//                    style: TextStyle(color: Colors.white,
//                        fontWeight: FontWeight.bold,
//                        fontSize: 14.0,
//                    fontFamily: "karla"),)),
//                ),
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: Center(
//                child: Text("Forgot password?",
//                style: TextStyle(
//                  color: Color(0xff6D00D9),
//                  fontSize: 14.0,
//                  fontFamily: "karla",
//                  decoration: TextDecoration.underline
//                ),),
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: Center(
//                child: Text("or connect with",
//                  style: TextStyle(
//                      fontSize: 16.0,
//                      fontFamily: "karla",
//                  ),),
//              ),
//            ),


//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: <Widget>[
//                  Padding(
//                    padding: const EdgeInsets.only(right: 20.0),
//                    child: InkWell(
//                      onTap: () {
//                        currentUser = User(
//                          id:'102559740660975769254',
//                          email: 'tempm7338@gmail.com',
//                          username: 'Jaskaran',
//                          photoUrl: ' https://lh3.googleusercontent.com/-2ZqfKtoAME4/AAAAAAAAAAI/AAAAAAAAAAA/AMZuucmTcfz1_oMIBZyhbPQkcUDZWwIluA/s96-c/photo.jpg',
//                          displayName: 'Temp Mail',
//                          bio: '',
//                        );
//                        setState(() {
//                          isAuth=true;
//                        });
//                      },
//                      child: Container(
//                        height: 46.0,
//                        width: 46.0,
//                        decoration: BoxDecoration(
//                            color: Colors.white,
//                            shape: BoxShape.circle,
//                            image: DecorationImage(image: AssetImage(
//                                "assets/images/linkedin.png"),
//                                fit: BoxFit.scaleDown),
//                          border: Border.all(color: Color(0xff6D00D9),width: 1.0)
//                          //borderRadius: BorderRadius.circular(30.0),
//                        ),
//                      ),
//                    ),
//                  ),
//                  Padding(
//                    padding: const EdgeInsets.only(left: 8.0),
//                    child: InkWell(
//                      onTap: () {
//                        login();
//                      },
//                      child: Container(
//                        height: 46.0,
//                        width: 46.0,
//                        decoration: BoxDecoration(
//                            color: Colors.white,
//                            shape: BoxShape.circle,
//                            image: DecorationImage(image: AssetImage(
//                                "assets/images/google.png"),
//                                fit: BoxFit.scaleDown),
//                          border: Border.all(color: Color(0xff6D00D9),width: 1.0)
//                          //borderRadius: BorderRadius.circular(30.0),
//                        ),
//                      ),
//                    ),
//                  )
//                ],
//              ),
//            )
          ],
        ),
      ),
    );
  }
//  Scaffold buildUnAuthScreen() {
//    return Scaffold(
//      body: Container(
//        decoration: BoxDecoration(
//          gradient: LinearGradient(
//            begin: Alignment.topRight,
//            end: Alignment.bottomLeft,
//            colors: [
//              Theme.of(context).accentColor,
//              Theme.of(context).primaryColor,
//            ],
//          ),
//        ),
//        alignment: Alignment.center,
//        child: Column(
//          mainAxisAlignment: MainAxisAlignment.center,
//          crossAxisAlignment: CrossAxisAlignment.center,
//          children: <Widget>[
//            Text(
//              'FlutterShare',
//              style: TextStyle(
//                fontFamily: "Signatra",
//                fontSize: 90.0,
//                color: Colors.white,
//              ),
//            ),
//            isWaiting ? GestureDetector(
//              onTap: login,
//              child: Container(
//                width: 260.0,
//                height: 60.0,
//                decoration: BoxDecoration(
//                  image: DecorationImage(
//                    image: AssetImage(
//                      'assets/images/google_signin_button.png',
//                    ),
//                    fit: BoxFit.cover,
//                  ),
//                ),
//              ),
//            )
//              : Text(""),
//            FlatButton(
//              child:Text("Developer Signin") ,
//                onPressed: (){
//                  currentUser = User(
//                    id:'102559740660975769254',
//                    email: 'tempm7338@gmail.com',
//                    username: 'Jaskaran',
//                    photoUrl: ' https://lh3.googleusercontent.com/-2ZqfKtoAME4/AAAAAAAAAAI/AAAAAAAAAAA/AMZuucmTcfz1_oMIBZyhbPQkcUDZWwIluA/s96-c/photo.jpg',
//                    displayName: 'Temp Mail',
//                    bio: '',
//                  );
//                  setState(() {
//                    isAuth=true;
//                  });
//                },
//            ),
//          ],
//        ),
//      ),
//    );
//  }

  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 2), (){
      if (this.mounted)setState(() {
          isWaiting=true;
          });
      });
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
