import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:social_networking/models/user.dart';
import 'package:social_networking/pages/home.dart';
import 'package:social_networking/pages/job_listing.dart';
import 'package:social_networking/pages/msgpage.dart';
import 'package:social_networking/pages/timeline.dart';
import 'package:social_networking/pages/view_profile.dart';

class JobHome extends StatefulWidget {
  final User currentUser;

  JobHome({this.currentUser});
  @override
  _JobHomeState createState() => _JobHomeState();
}

class _JobHomeState extends State<JobHome> {
  List<String> jobName = [
    "Development",
    "Management",
    "Design",
    "Marketing",
    "Data Science"
  ];
  String jobDescription =
      "NodeJs development,front end development,UI design &12 more";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          "assets/images/precisely_logo.png",
          height: 40.0,
          width: 40.0,
        ),
        iconTheme: new IconThemeData(color: Color(0xff8B8B8B)),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.search,
                size: 35.0,
              ),
              onPressed: () {}),
          IconButton(
            icon: Image.asset("assets/images/msgicon.png"),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return MessagePage();
                  },
                ),
              );
            },
          )
        ],
      ),
      drawer: buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Card(
                elevation: 5,
                child: Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Applied Jobs"),
                          Text(
                            "5",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          )
                        ],
                      ),
                      VerticalDivider(
                        thickness: 2,
                        color: Colors.grey[300],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Saved Jobs"),
                          Text(
                            "12",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Text(
                "Based on your profile",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            ListView.builder(
                padding: const EdgeInsets.all(10.0),
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemCount: jobName.length,
                itemBuilder: (ctx, index) {
                  return Card(
                    elevation: 5,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15.0),
                      title: Text(
                        jobName[index],
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      subtitle: Text(jobDescription),
                      trailing: Icon(
                        Icons.arrow_forward,
                        color: Theme.of(context).primaryColor,
                      ),
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) {
                          return JobListing();
                        }));
                      },
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }

  Drawer buildDrawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 40.0,
                  backgroundColor: Colors.grey,
                  backgroundImage:
                      CachedNetworkImageProvider(currentUser.photoUrl),
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  children: <Widget>[
                    Text(
                      currentUser.username,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "450 Connections",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                  return ViewProfile(
                    profileId: currentUser.id,
                  );
                }));
              },
              child: Text(
                "View Profile",
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 16.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Divider(
              thickness: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Settings & Privacy",
              style: TextStyle(fontSize: 15.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Divider(
              thickness: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Groups",
              style: TextStyle(fontSize: 15.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Divider(
              thickness: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Events",
              style: TextStyle(fontSize: 15.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: Text(
              "+ Add event",
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 15.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Divider(
              thickness: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Hashtags",
              style: TextStyle(fontSize: 15.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: Text(
              "#india",
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 15.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Divider(
              thickness: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Terms & Conditions",
              style: TextStyle(fontSize: 15.0),
            ),
          )
        ],
      ),
    );
  }
}
