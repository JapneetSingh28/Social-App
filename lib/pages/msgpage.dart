import 'package:flutter/material.dart';
class MessagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Coming soon",
        style: TextStyle(
          color: Color(0xff6D00D9),
          fontFamily: "karla",
          fontSize: 20.0,
          fontWeight: FontWeight.bold
        ),),
      ),
    );
  }
}
