import 'package:flutter/material.dart';
import 'package:sensational_science/Services/projectDB.dart';
import '../../models/project.dart';
import '../../Services/getproject.dart';
import 'textquestion.dart';
import 'multiplechoicequestion.dart';
import 'package:sensational_science/Screens/Teacher/FormInputs/multiplechoice.dart';
import 'package:sensational_science/Screens/Teacher/FormInputs/userlocation.dart';
import 'package:sensational_science/Screens/Teacher/FormInputs/textInputItem.dart';
import 'package:sensational_science/Screens/Teacher/FormInputs/image_capture.dart';
import 'package:sensational_science/Screens/Teacher/FormInputs/shortAnswer.dart';
import 'package:sensational_science/Screens/Teacher/FormInputs/numericalInput.dart';
//import 'package:flutter_conditional_rendering/flutter_conditional_rendering.dart';

var createLocationHandler = new UserLocation();

var locationResult = createLocationHandler.getUserLocation();

var createTextInputHandler =
    new TextInputItem(controller: new TextEditingController());

var createMultipleChoice = new MultipleChoice();

var createImageCapture = new AddImageInput();

var createShortAnswer = new ShortAnswerItem();

var createNumericalInput = new NumericalInputItem();

class ViewProject extends StatefulWidget {
  String docIDref;
 String title;
//GetProject project;
  ViewProject(title, docID){
    this.docIDref = docID;
     this.title = title;


  }

  @override
  _ViewProjectState createState() => _ViewProjectState(this.title, this.docIDref);
}

class _ViewProjectState extends State<ViewProject> {
  GetProject project;
  bool done= false;
  _ViewProjectState(String title, String docID) {
    project=new GetProject(title, docID);
    //project.questionData();
     //project.questionData();
   
  
  }
  int _currentQuestion = 0;
  Future questionFuture;
  
  
  Future<int> _getType(_currentQuestion) async {
    if(_currentQuestion < project.questions.length){
    switch(project.questions[_currentQuestion].type){
      case 'TextInputItem':
        return 0;
      case 'MultipleChoice':
        return 1;
      case 'ShortAnswerItem':
        return 2;
      case 'UserLocation':
        return 3; 
    }}
    else{
    return -1;
  }
  }
   

   void renderPage()async {
     if(project.questions.length > 0){
     setState(() {
       done=true;
     });
     }
     setState(() {
       
     });
   }
  /* 
   Widget build(BuildContext context){
   
     if(done){
       
       return mainScreen(context);
     }
     else{
       renderPage();
       
       return CircularProgressIndicator();
     }
   }
*/
   
Widget build(BuildContext context) {

  return new MaterialApp(
      
      home: new Scaffold(
          appBar: AppBar(title: Text("Random Widget")),
          body: 
          project.questions.length == 0
          
         ? Center(child: CircularProgressIndicator()
          
              
         )
         :
          Center(
          
            child:
      
          FutureBuilder(
              initialData: 0,
              future: _getType(_currentQuestion),
              builder: (context, snapshot) {
              /*switch(snapshot.connectionState){
                case ConnectionState.waiting: 
                  return CircularProgressIndicator();
                case ConnectionState.done:
                  return getQuestionWidget();
                default:
              }*/

                if(project.questions.length>0){
                  return getQuestionWidget(snapshot.data);
               }
              else{
                  
                  return CircularProgressIndicator();
               }
              }
          )
     // )
      ),
    ),
  );
}

/*
Widget mainScreen(BuildContext context){
 
    /*return new MaterialApp(
      
      home: new Scaffold(
          appBar: AppBar(title: Text("Random Widget")),
          body: project.questions.length == 0
          ? Center(child: CircularProgressIndicator()
          
              
          )
          :
      */
      Center(child:
          FutureBuilder(
              initialData: 0,
              future: _getType(_currentQuestion),
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  return getQuestionWidget(snapshot.data);
                }
                else{
                  
                  return getQuestionWidget(-1);
                }
              },
          ),
      );
        //  )
     // )),
   // );
  }
*/
   Widget getQuestionWidget(int number) {
     
    switch(number){
      case 0:
        return Column(children: <Widget>[
          Text("TextInputItem", textScaleFactor: 4),
          getNextButton()
        ]);
        break;
      case 1:
        return Column(children: <Widget>[
          Text("MultipleChoice", textScaleFactor: 4),
          getNextButton()
        ]);
        break;
      case 2:
        return Column(children: <Widget>[
          Text("ShortAnswer", textScaleFactor: 4),
          getNextButton()
        ]);
        break;
      case 3:
        return Column(children: <Widget>[
          Text("UserLocation", textScaleFactor: 4),
          getNextButton()
        ]);
        break;
      case -1:
        return Column(children: <Widget>[
          Text("Submit Page", textScaleFactor: 4),
          //getNextButton()
        ]);
    }
  }


Widget getNextButton(){
      return RaisedButton(
          child: Text("NEXT"),
          color: Colors.red,
          onPressed: () {
            if(_currentQuestion < project.questions.length){
                //return getQuestionWidget();
                setState(() {
                  _currentQuestion++;
                  _getType(_currentQuestion);
                });
               // _currentQuestion++;
                
            }
            return getQuestionWidget(-1); 
            //setState(() {
              
              //_currentQuestion++;
              //return getQuestionWidget();

              //_getType(_currentQuestion);
           // });

          }
      );
  }


  @override
  void initState() {
    
    setState(() {
     _getQuestions();
    });
   // done=false;
    super.initState();
    
  }

  Future<void> _getQuestions() async {
    // you mentioned you use firebase for database, so
    // you have to wait for the data to be loaded from the network
    await project.questionData();
    setState(() {
      
    });
    
   
   
  }

  // Call this function when you want to move to the next page
  void goToNextPage() {
    //setState(() {
      _currentQuestion++;
   // });
  }


}