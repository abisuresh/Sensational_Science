import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sensational_science/Screens/Student/student_collect_data.dart';
import 'package:sensational_science/Screens/Teacher/FormInputs/imageCapture/imageCaptureService.dart';
import 'package:sensational_science/Services/projectDB.dart';
import 'package:sensational_science/Shared/styles.dart';
import '../../Services/getproject.dart';
import 'package:sensational_science/Screens/Teacher/textquestion.dart';
import 'package:sensational_science/Screens/Teacher/multiplechoicequestion.dart';
import 'package:sensational_science/Screens/Teacher/shortanswerquestion.dart';
import 'package:sensational_science/Screens/Teacher/numericalquestion.dart';
import 'package:sensational_science/Screens/Teacher/UserLocationInfo.dart';
import '../../Services/projectDB.dart';
import 'package:sensational_science/models/student.dart';
import 'package:sensational_science/Services/storeLocally.dart';
import 'dart:io';
import 'student_home.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CollectDataPage extends StatelessWidget {
  final String projectID;
  final String title;
  final String code;
  final GetProject project;
  CollectDataPage(this.title, this.projectID, this.code, this.project);

  Widget build(BuildContext context) {
    final Student student = new Student(code: code);
    return new Observation(
        key: new Key(projectID),
        projectID: this.projectID,
        answers: new Map(),
        child: new CollectData(student, this.project));
  }
}

class CollectData extends StatefulWidget {
  final Student student;
  final GetProject project;
  List<TextEditingController> controllers = [new TextEditingController()];
  List<int> questionType = [6];

  CollectData(this.student, this.project) {
    for (int i = 1; i < project.questions.length; i++) {
      controllers.add(new TextEditingController());
      questionType.add(6);
      //print("Values of i " + i.toString());
    }
  }

  AddProject proj;

  @override
  _CollectDataState createState() => _CollectDataState();
}

class _CollectDataState extends State<CollectData> {
  List<dynamic> answers = new List();
bool _checkforAnswers(){
  bool retVal = false;
  widget.controllers.forEach((element) {
    if(element.text == null || element.text == ""){
      retVal = true;
    }
  });
  return retVal;

}
  _submitProj(String code) async {
    DocumentReference docRef =
        Firestore.instance.collection('codes').document(code);
    FirebaseStorage _storage =
        FirebaseStorage(storageBucket: 'gs://citizen-science-app.appspot.com');
    String data;
    File image;
    StorageUploadTask _uploadTask;
    List<String> answerList = new List();

    //if the app is not on the web, pull data from local storage
    if (kIsWeb) {
      answers.forEach((element) {
        docRef.updateData({
          'Answers': FieldValue.arrayUnion([element]),
        });
      });
    } else {
      for (var i = 0; i < widget.controllers.length; i++) {
        data = await readString(code, i.toString());
        answerList.add(data);
        if (widget.questionType[i] == 5) {
          image = await getImage(code, i.toString());
          _uploadTask = _storage.ref().child(data).putFile(image);
          await _uploadTask.onComplete;
        }
      }
      docRef.setData({'Answers': answerList}, merge: true);
    }
  }

  int _currentQuestion = 0;

  Future<int> _getType(_currentQuestion) async {
    if (_currentQuestion < widget.project.questions.length) {
      switch (widget.project.questions[_currentQuestion].type) {
        case 'TextInputItem':
          return 0;
        case 'MultipleChoice':
          return 1;
        case 'ShortAnswerItem':
          return 2;
        case 'UserLocation':
          return 3;
        case 'NumericalInputItem':
          return 4;
        case 'AddImageInput':
          return 5;
      }
    }
  }

  Widget build(BuildContext context) {
    return Container(
      child: new MaterialApp(
        theme: appTheme,
        
        home: new Scaffold(
          appBar: AppBar(
              title: Text("Collect Data For Your Project"),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context, false),
              ),
              //backgroundColor: Colors.deepPurple,
              ),
          body: widget.project.questions.length == 0
              ? Center(
                  child: Column(children: <Widget>[
                    Card(
                      child: Text(widget.project.title),
                    ),
                    RaisedButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: Text('Click to View Questions'),
                      //color: Colors.blue,
                    ),
                  ]),
                )
              : Center(
                  child: FutureBuilder(
                      future: _getType(_currentQuestion),
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          return getQuestionWidget(context, snapshot.data);
                        } else if (_currentQuestion >=
                            widget.project.questions.length) {
                          return getQuestionWidget(context, -1);
                        } else {
                          return CircularProgressIndicator();
                        }
                      })),
          
        ),
      ),
    );
  }

  Widget getNextButton(BuildContext context) {
    return RaisedButton(
        child: Text("NEXT"),
        color: Colors.red,
        onPressed: () {
          if (kIsWeb) {
            //store data in app
            if(answers.length == _currentQuestion) {
              answers.add(widget.controllers[_currentQuestion].value.text);
            } else {
              answers[_currentQuestion] = (widget.controllers[_currentQuestion].value.text);
            }
          } else {
            answers.add(widget.controllers[_currentQuestion].value.text);
            //store data locally
            writeString(
                widget.student.code,
                widget.controllers[_currentQuestion].value.text,
                _currentQuestion.toString());
          }

          if (_currentQuestion < widget.project.questions.length) {
            setState(() {
              _currentQuestion++;
              _getType(_currentQuestion);
            });
          }
        });
  }

  Widget getPrevButton(BuildContext context) {
    return RaisedButton(
        child: Text("Prev"),
        color: Colors.red,
        onPressed: () {
          if (_currentQuestion > 0) {
            setState(() {
              _currentQuestion--;
              _getType(_currentQuestion);
            });
          } else {
            Navigator.of(context).pop();
          }
        });
  }

  Widget getQuestionWidget(BuildContext context, int number) {
    if (_currentQuestion < widget.project.questions.length) {
      switch (number) {
        case 0:
          widget.questionType[_currentQuestion] = 0;
          return Column(children: <Widget>[
            Container(
              padding: EdgeInsets.all(16.0),
              width: MediaQuery.of(context).size.width / 1.2,
              child: Text("#" + (_currentQuestion + 1).toString() + ": " +
                  widget.project.questions[_currentQuestion].question, style: TextStyle(fontSize: 20)),
            ),
            Container(
              margin: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width / 1.33,
              child: Center(
                  child: FutureBuilder(
                      future: readString(
                          widget.student.code, _currentQuestion.toString()),
                      builder: (context, AsyncSnapshot<String> answer) {
                        if (answer.hasData && answer.data != '!ERROR!') {
                          widget.controllers[_currentQuestion].text =
                              answer.data;
                        }
                        return new TextQuestionWidget(
                          textAnswerController:
                              widget.controllers[_currentQuestion],
                        );
                      })),
            ),
            getNextButton(context),
            getPrevButton(context)
          ]);
          break;
        case 1:
          widget.questionType[_currentQuestion] = 1;
          return SingleChildScrollView( child:Column(
            children: <Widget>[
            Container(
              padding: EdgeInsets.all(16.0),
              width: MediaQuery.of(context).size.width / 1.2,
              child: Text("#" + (_currentQuestion + 1).toString() + ": " +
                  widget.project.questions[_currentQuestion].question, style: TextStyle(fontSize: 20)),
            ),
              Container(
                margin: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width / 1.33,
                child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: FutureBuilder(
                        future: readString(
                            widget.student.code, _currentQuestion.toString()),
                        builder: (context, AsyncSnapshot<String> answer) {
                          if (answer.hasData && answer.data != '!ERROR!') {
                            widget.controllers[_currentQuestion].text =
                                answer.data;
                          }
                          return new MultQuestionWidget(
                              question:
                                  widget.project.questions[_currentQuestion],
                              multChoiceController:
                                  widget.controllers[_currentQuestion]);
                        })),
              ),
              getNextButton(context),
              getPrevButton(context)
            ],
          ));
          break;
        case 2:
          widget.questionType[_currentQuestion] = 2;
          return SingleChildScrollView(child:Column(children: <Widget>[
            Container(
              padding: EdgeInsets.all(16.0),
              width: MediaQuery.of(context).size.width / 1.2,
              child: Text("#" + (_currentQuestion + 1).toString() + ": " +
                  widget.project.questions[_currentQuestion].question, style: TextStyle(fontSize: 20)),
            ),
            Container(
                margin: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width / 1.33,
                child: FutureBuilder(
                    future: readString(
                        widget.student.code, _currentQuestion.toString()),
                    builder: (context, AsyncSnapshot<String> answer) {
                      if (answer.hasData && answer.data != '!ERROR!') {
                        widget.controllers[_currentQuestion].text = answer.data;
                      }
                      return new ShortAnswerQuestion(
                          shortAnswerController:
                              widget.controllers[_currentQuestion]);
                    })),
            getNextButton(context),
            getPrevButton(context)
          ]));
          break;
        case 3:
          widget.questionType[_currentQuestion] = 3;
          var questionNum = _currentQuestion; 
          var code = widget.student.code; 
          return SingleChildScrollView(child: Column(
            children: <Widget>[
            Container(
              padding: EdgeInsets.all(16.0),
              width: MediaQuery.of(context).size.width / 1.2,
              child: Text("#" + (_currentQuestion + 1).toString() + ": " +
                  widget.project.questions[_currentQuestion].question, style: TextStyle(fontSize: 20)),
            ),
              Container(
                margin: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width / 1.33,
                child: FutureBuilder(
                    future: readString(
                        widget.student.code, _currentQuestion.toString()),
                    builder: (context, AsyncSnapshot<String> answer) {
                      if (answer.hasData && answer.data != '!ERROR!') {
                        widget.controllers[_currentQuestion].text = answer.data;
                      }
                      return new UserLocationInfo(
                        userLocationController: widget.controllers[_currentQuestion],
                        code : widget.student.code,
                        questionNum: questionNum
                      );
                    })),
            getNextButton(context),
            getPrevButton(context)
          ]));
          break;
        case 4:
          widget.questionType[_currentQuestion] = 4;
          return SingleChildScrollView(child: Column(children: <Widget>[
            Container(
              padding: EdgeInsets.all(16.0),
              width: MediaQuery.of(context).size.width / 1.2,
              child: Text("#" + (_currentQuestion + 1).toString() + ": " +
                  widget.project.questions[_currentQuestion].question, style: TextStyle(fontSize: 20)),
            ),
            Container(
                margin: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width / 1.33,
                child: FutureBuilder(
                    future: readString(
                        widget.student.code, _currentQuestion.toString()),
                    builder: (context, AsyncSnapshot<String> answer) {
                      if (answer.hasData && answer.data != '!ERROR!') {
                        widget.controllers[_currentQuestion].text = answer.data;
                      }
                      return new NumericalQuestion(
                          numAnswerController:
                              widget.controllers[_currentQuestion]);
                    })),
            getNextButton(context),
            getPrevButton(context)
          ]));
          break;
        case 5:
          widget.questionType[_currentQuestion] = 5;
          return SingleChildScrollView(child: Column(children: <Widget>[
            Container(
              padding: EdgeInsets.all(16.0),
              width: MediaQuery.of(context).size.width / 1.2,
              child: Text("#" + (_currentQuestion + 1).toString() + ": " +
                  widget.project.questions[_currentQuestion].question, style: TextStyle(fontSize: 20)),
            ),
            Container(
              margin: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width / 1.33,
              child: FutureBuilder(
                  future: readString(
                      widget.student.code, _currentQuestion.toString()),
                  builder: (context, answer) {
                    if (answer.hasData && answer.data != '!ERROR!') {
                      widget.controllers[_currentQuestion].text = answer.data;
                    }
                    return RaisedButton(
                      child: Text('Click to upload or take photo'),
                      onPressed: () async {
                        File preFilledFile;
                        if (!kIsWeb && widget.controllers[_currentQuestion].text != null) {
                          //print(widget.controllers[_currentQuestion].text);
                          preFilledFile = await getImage(
                              widget.student.code, _currentQuestion.toString());
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ImageCapture(
                              student: widget.student,
                              questionNum: _currentQuestion.toString(),
                              imgLocController:
                                  widget.controllers[_currentQuestion],
                              imageFile: preFilledFile,
                            ),
                          ),
                        );
                      },
                    );
                  }),
            ),
            //DO NOT DELETE - Working on previewing photo, only works with first loaded photo
            // Container(
            //   margin: EdgeInsets.all(10),
            //   width: MediaQuery.of(context).size.width / 1.2,
            //   child: FutureBuilder(
            //       future: getImage(widget.student.code, _currentQuestion.toString()),
            //       builder: (context, answer) {
            //         if (!answer.hasData) return Text('');
            //         if (answer.data == null) return Text('');
            //         return Container(
            //           padding: EdgeInsets.all(10.0),
            //           height: MediaQuery.of(context).size.height * 0.4,
            //           child: new Image.file(answer.data,
            //           height: MediaQuery.of(context).size.height * 0.3,),
            //           );
            //       }),
            // ),
            getNextButton(context),
            getPrevButton(context)
          ]));
          break;
      }
    } else {
      return Column(children: <Widget>[
        Text("Submit Page", textScaleFactor: 4),
        RaisedButton(
          child: Text('Go back and review answers'),
          onPressed: () => {
            setState(() {
              _currentQuestion = 0;
            }),
            //getQuestionWidget(),
          },
        ),
        RaisedButton(
          child: Text('Submit Project'),
          onPressed: () => {
            if(_checkforAnswers()){
                 showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("One or more of your answers is empty!"),
                  content: Text(
                      "Your must submit an answer for each question!"),
                  actions: <Widget>[
                    RaisedButton(
                      child: Text("Close"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              }
                 ),

            }
            else{

            
            _submitProj(widget.student.code),
            Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => StudentHome(classData: widget.student.code)),
                  (Route<dynamic> route) => false,
                ),
         
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Success!"),
                  content: Text(
                      "Your project has been submitted! After the due date you can view the compiled answers!"),
                  actions: <Widget>[
                    RaisedButton(
                      child: Text("Close"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            ),
            }
          },
        )
      ]);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _getQuestions() async {
    await widget.project.questionData();
    setState(() {});
  }

  // Call this function when you want to move to the next page
  void goToNextPage() {
    _currentQuestion++;
  }
}
