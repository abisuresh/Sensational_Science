import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';

import 'package:provider/provider.dart';
import 'package:sensational_science/models/user.dart';



class AddRoster extends StatefulWidget{
  final String name;
  AddRoster({this.name});
 @override
  _AddRosterState createState() => _AddRosterState();
}


class _AddRosterState extends State<AddRoster>{
  String name;
  List<DynamicWidget> roster=[];

  addStudent(){
    roster.add(new DynamicWidget());
    setState((){
    });
  }

 submitData(teachID) async {
  //String val='Success!';
  roster.forEach((e){
    Firestore.instance
      .runTransaction((transaction) async{
        await transaction.set(Firestore.instance
          .collection("Teachers")
          .document(teachID)
          .collection('Classes')
          .document(widget.name)
          .collection('Roster')
          .document(),
          {
            'name': e.controller.text,
          }
        );
      }
    ); 
  });
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Students added!'),
        content: Text('Students have been added to the class'),
        actions: <Widget>[
          RaisedButton(child: Text("Close"),
            onPressed: () {Navigator.of(context).pop();},
          ),
        ]
      );
    },
  );
  roster = [];
  setState(() {});
}

  /*
  List<String> tags = List.from(doc.data['name']);
  
    if(tags.contains(element.controller.text)==true){
    
    docRef.addData({
      'Name' : FieldValue.arrayRemove([element.controller.text])
    });
    
  }
  else{
    docRef.updateData(
      {
      'Name' : FieldValue.arrayUnion([element.controller.text])
      });
  }
  });
  
  roster.forEach(
    (widget)=>print(widget.controller.text)
  );
}
*/
String success = '';
@override

  Widget build(BuildContext context){
  final user = Provider.of<User>(context);
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text("View & Add To Roster"),
        ),
        body: new Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              new Text('Current Roster'),
              new StreamBuilder(
                stream: Firestore.instance.collection('Teachers').
                  document(user.uid)
                  .collection('Classes')
                  .document(widget.name)
                  .collection('Roster')
                  .snapshots(),
                builder: (BuildContext context, snapshot) {
                  if(!snapshot.hasData) return new Text('...Loading');
                  return new Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: new ListView(
                        children: snapshot.data.documents.map<Widget>((doc){
                          return new ListTile(
                            title: new Text(doc['name']),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
              new Divider(
                color: Colors.blue,
                height: 10.0,
              ),
              new Text('Students to add:'),
              new Expanded(
                child: new ListView.builder(
                  itemCount: roster.length,
                  itemBuilder: (_, index)=>roster[index]
                ),
              ),
                new Container(
                child: Text(success),
              ),
              new RaisedButton(
                child: new Text('Submit Students'),
                onPressed: ()=> submitData(user.uid),
              ),
              new RaisedButton(
                child: new Text('Add Another Student'),
                onPressed: addStudent,
              ),
            ],
          ),
        ),
        floatingActionButton: new RaisedButton(
          onPressed: () { Navigator.pop(context);},
          child: Text('Go Back'),
        ),
      ),
    );
    
  
}
}

class DynamicWidget extends StatelessWidget{
  final controller = new TextEditingController();
  @override
  Widget build(BuildContext context){
    return Container(
      margin: new EdgeInsets.all(8.0),
      child: new TextField(
        controller: controller,
        decoration: new InputDecoration(hintText: 'Enter Student Name'),
      ),
    );
  }
}