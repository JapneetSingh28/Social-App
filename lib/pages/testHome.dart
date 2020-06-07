import 'package:flutter/material.dart';
import 'test.dart';
import 'package:social_networking/models/question.dart';
class TestHome extends StatelessWidget {
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
      ),
      body: GridView.count(
        // Create a grid with 2 columns. If you change the scrollDirection to
        // horizontal, this produces 2 rows.
        crossAxisCount: 2,
        // Generate 100 widgets that display their index in the List.
        children: List.generate(subjects.length, (index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                  return Evaluation(subject: subjects[index],);
                }));
              },
              child: Card(
                elevation: 4.5,
                child: Center(
                  child: Text(
                    subjects[index],
                    style: Theme.of(context).textTheme.headline,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
