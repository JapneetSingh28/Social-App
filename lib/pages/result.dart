import 'package:flutter/material.dart';

class Result extends StatelessWidget {
  int score;

  Result(this.score);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        title:  Image.asset(
//          "assets/images/precisely_logo.png",
//          height: 40.0,
//          width: 40.0,
//        ),
//        backgroundColor: Colors.white,
//        iconTheme: new IconThemeData(color: Color(0xff8B8B8B)),
//        centerTitle: true,
//      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            Image.asset("assets/images/quiz.jpg",
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,),
            Align(
                alignment: Alignment.center,
                child: Text("Your score is: $score/10",
            style: TextStyle(fontFamily: "karla",
            fontSize: 24.0,color: Colors.white,
            fontWeight: FontWeight.bold),)),
          ],
        ),
      ),
    );
  }
}