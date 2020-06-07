import 'package:flutter/cupertino.dart';
import 'package:social_networking/models/question.dart';
import 'package:flutter/material.dart';
import 'result.dart';
class Evaluation extends StatefulWidget {
  String subject;
  Evaluation({this.subject});

  @override
  _EvaluationState createState() => _EvaluationState();
}

class _EvaluationState extends State<Evaluation> {
  Question question;
  PageController controller = PageController();
  List QuestionBank;
  int index;
  int i=4;
  List score=[0,0,0,0,0,0,0,0,0,0];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    question=Question(widget.subject);
    QuestionBank=question.questions();
    index=0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Image.asset(
          "assets/images/precisely_logo.png",
          height: 40.0,
          width: 40.0,
        ),
        backgroundColor: Colors.white,
        iconTheme: new IconThemeData(color: Color(0xff8B8B8B)),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
            child: Text("Submit"),
            onPressed: (){
              int sum=0;
              for(i=0;i<score.length;i++){
                sum=sum+score[i];
              }
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context){
                return Result(sum);
              }));
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top:8.0),
        child: Container(
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Q${index+1}. ${QuestionBank[index]["question"]}",style: TextStyle(fontSize: 18.0,fontFamily: "karla"),),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Options:",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold,fontFamily: "karla"),),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: (){
                    int marks=0;
                    if(QuestionBank[index]["answer"]==0){
                      marks=1;
                    }
                    setState(() {
                      score[index]=marks;
                      i=0;
                    });
                  },
                  child: Card(
                      elevation: 2.5,
                      child: Container(
                          color:i==0?Color(0xff6D00D9):Colors.white,
                          height: 40.0,
                          child: Center(child: Text(" ${QuestionBank[index]["option"][0]}",
                            style: TextStyle(color:i==0?Colors.white:Colors.black,
                            fontFamily: "karla"),)))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: (){
                    int marks=0;
                    if(QuestionBank[index]["answer"]==1){
                      marks=1;
                    }
                    setState(() {
                      score[index]=marks;
                      i=1;
                    });
                  },
                  child: Card(
                      elevation: 2.5,
                      child: Container(
                          height: 40.0,
                          color:i==1?Color(0xff6D00D9):Colors.white,
                          child: Center(child: Text(" ${QuestionBank[index]["option"][1]}",
                            style: TextStyle(color:i==1?Colors.white:Colors.black,
                            fontFamily: "karla"),)))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: (){
                    int marks=0;
                    if(QuestionBank[index]["answer"]==2){
                      marks=1;
                    }
                    setState(() {
                      score[index]=marks;
                      i=2;
                    });
                  },
                  child: Card(
                      elevation:2.5,
                      child: Container(
                          color:i==2?Color(0xff6D00D9):Colors.white,
                          height: 40.0,
                          child: Center(child: Text(" ${QuestionBank[index]["option"][2]}",
                            style: TextStyle(color:i==2?Colors.white:Colors.black,
                            fontFamily: "karla"),)))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: (){
                    int marks=0;
                    if(QuestionBank[index]["answer"]==3){
                      marks=1;
                    }
                    setState(() {
                      score[index]=marks;
                      i=3;
                    });
                  },
                  child: Card(
                      elevation: 2.5,
                      child: Container(
                          height: 40.0,
                          color:i==3?Color(0xff6D00D9):Colors.white,
                          child: Center(child: Text(" ${QuestionBank[index]["option"][3]}",
                            style: TextStyle(color:i==3?Colors.white:Colors.black,
                            fontFamily: "karla"),)))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top:60.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(onPressed: (){
                      if(index>=0)
                        setState(() {
                          index=index-1;
                          i=4;
                        });
                    },
                        color: Color(0xff6D00D9),
                        child: Icon(Icons.arrow_back,color: Colors.white,)),
                    RaisedButton(onPressed: (){
                      if(index<QuestionBank.length-1)
                        setState(() {
                          index=index+1;
                          i=4;
                        });
                    },
                        color: Color(0xff6D00D9),
                        child: Icon(Icons.arrow_forward,color: Colors.white,))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
