import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sensational_science/Screens/Login/login_auth.dart';
import 'dart:async';

class StagingPage extends StatefulWidget {
  @override

  _StagingPageState createState() => _StagingPageState();
}

class _StagingPageState  extends State<StagingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordCheckController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  findUser(idUser) async {
    var data = Firestore.instance.collection('Teachers').document(idUser).get();
    await data.then((user) {
      return user.exists;
    });
  }

class _StagingPageState extends State<StagingPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("Create Account"),
        ),
        backgroundColor: Colors.lightBlue[100],
        body: Form(
            key: _formKey,
            child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(children: <Widget>[
                  //Text form fields and raised button
                  TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    maxLines: 1,
                    controller: firstNameController,
                    decoration: const InputDecoration(hintText: 'First Name'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your first name.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    maxLines: 1,
                    controller: lastNameController,
                    decoration: const InputDecoration(hintText: 'Last Name'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your last name.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    maxLines: 1,
                    controller: emailController,
                    decoration: const InputDecoration(
                        hintText: 'Enter an email address'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter an email address.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    maxLines: 1,
                    controller: passwordController,
                    obscureText: true, 
                    decoration:
                        const InputDecoration(hintText: 'Enter a password'),
                    validator: (value) {
                      if (value.isEmpty||value.length < 6) {
                        return 'Please enter a password at least characters in length.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    maxLines: 1,
                    controller: passwordCheckController,
                    obscureText: true, 
                    decoration:
                        const InputDecoration(hintText: 'Re-enter password'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please re-enter password.';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(child: Text('Create Account'),
                     onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        // dynamic result = await authorization.createUserAccount(emailController.text, passwordController.text); 
                        if (passwordController.text ==
                            passwordCheckController.text) {
                              //add fname and lname to create the user account
                              createAccountHandler.createUserAccount(emailController.text, passwordController.text, firstNameController.text, lastNameController.text)
                              .then((FirebaseUser user){
                                Navigator.pop(context); 
                              }).catchError((ex) => print(ex));
                            }
                  
                        else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                    title: Text("Mismatched passwords"),
                                    content: Text(
                                        "The passwords you entered did not match"),
                                    actions: <Widget>[
                                      RaisedButton(
                                        child: Text("Close"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ]);
                              });
                        }
                      }
                    },
                    // child: Text('Create Account')
                  )),
                ]))));
  }
}

