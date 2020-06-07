import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:social_networking/widgets/header.dart';

class ChattingScreen extends StatefulWidget {
  @override
  _ChattingScreenState createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: header(context,titleText: "Messanging"),
      body:
//      Container(),);
      WebviewScaffold(withJavascript: true,withZoom: true,resizeToAvoidBottomInset: true,
        url: "https://secret-ridge-46753.herokuapp.com/",
        appBar:  header(context,titleText: "Messanging"),));
  }
}
