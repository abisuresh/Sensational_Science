import 'package:flutter/material.dart';
import 'package:sensational_science/Services/getproject.dart';


class PreviewProject extends StatefulWidget {
  final String title;
  final GetProject proj;
  PreviewProject({this.proj, this.title});
  @override
  _PreviewProjectState createState() => _PreviewProjectState(this.proj);
}

class _PreviewProjectState extends State<PreviewProject> {
  GetProject proj;
  List<DynamicWidget> questions = new List();
  _PreviewProjectState(GetProject proj){
    this.proj=proj;
    proj.questions.forEach((element) {
      questions.add(new DynamicWidget(type: element.type, numq: element.number, question: element.question, answers: element.answers));
   
    });

  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Add Questions To the Project'),
                          leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context, false),
                )
        ),
        body: Column(
          children: <Widget>[
             Expanded(
              child: new ListView.builder(
                  itemCount: widget.proj.questions.length,
                  itemBuilder: (_, index) => this.questions[index]),
            ),
          
          ]
        ),            
                            
                     
                
          
      ),
    );
  }
}



class DynamicWidget extends StatefulWidget {
  final String question;
  // final answercontroller = new List<TextEditingController>();
  final answerWidget = new List<DynamicAnswers>();
  final List<String> answers;
  int numAnswers = 0;
  final String type;
  final int numq;

  DynamicWidget({this.type, this.numq, this.question, this.answers});
  @override
  _DynamicWidgetState createState() => _DynamicWidgetState();
}

class _DynamicWidgetState extends State<DynamicWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.type == "MultipleChoice") {
      int ansNum=0;
      widget.answers.forEach((element) {
        widget.answerWidget.add(new DynamicAnswers(answer: element, numAnswer: ansNum));
        ansNum++;
      });
      return Container(
          // constraints: BoxConstraints(minWidth: 230.0, minHeight: 25.0),
          margin: new EdgeInsets.all(8.0),
          child: Column(
      children: <Widget>[
        new Text("Question Number: " + widget.numq.toString(),
          style: TextStyle(fontSize: 20)),
        new Text("Type: " + widget.type),
         new Text("Question: " + widget.question, style: TextStyle(fontSize: 30)),
        new ListView.builder(
            shrinkWrap: true,
            itemCount: widget.answers.length,
            itemBuilder: (_, index) => widget.answerWidget[index]),
      ],
            ),
        );
    } else {
      return Container(
        margin: new EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            new Text("Question Number: " + widget.numq.toString(),
                style: TextStyle(fontSize: 20)),
            new Text("Type: " + widget.type),
            new Text("Question: " + widget.question, style: TextStyle(fontSize: 30)),
            new Text("Answers: "),
          ],
        ),
      );
    }
  }
}

class DynamicAnswers extends StatelessWidget {
  final String answer;
  final int numAnswer;
  DynamicAnswers({this.answer, this.numAnswer});
 
  @override
  Widget build(BuildContext context) {
    return Container(
     
      width: MediaQuery.of(context).size.width / 2,
        child: SizedBox(
      width: 50,
      child: Text("Answer " + this.numAnswer.toString() + ": " + this.answer),
      
    ));
  }
}