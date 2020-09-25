import 'package:flutter/material.dart';
import 'package:status_checker/views/options.dart';
import 'package:status_checker/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:status_checker/helper/helperfunctions.dart';
import 'package:status_checker/services/database.dart';
import 'package:status_checker/services/auth.dart';

class SignIn extends StatefulWidget {
  final Function toggle;
  SignIn(this.toggle);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final formKey = GlobalKey<FormState>();
  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();

  bool isLoading = false;
  QuerySnapshot snapshotUserInfo;

  signIn() {
    if (formKey.currentState.validate())
      HelperFunctions
          .saveUserEmailSharedPreference(emailTextEditingController.text);

    setState(() {
      isLoading = true;
    });
    databaseMethods.getUserByUserEmail(emailTextEditingController.text)
        .then((val) {
      snapshotUserInfo = val;
      HelperFunctions
          .saveUserEmailSharedPreference(
          snapshotUserInfo.documents[0].data["name"]);
    });

    authMethods.signInWithEmailAndPassword(emailTextEditingController.text,
        passwordTextEditingController.text).then((val) {
      if (val != null) {
        HelperFunctions.saveUserLoggedInSharedPreference(true);
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => option()
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: appBarMain(context),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height-50,
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        validator: (val){
                          return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(val)? null : "Please provide valid email id";
                        },
                        controller: emailTextEditingController,
                        style: simpleTextStyle(),
                        decoration: textFieldInputDecoration('email'),
                      ),
                      TextFormField(
                          validator: (val){
                            return val.length > 6 ? null :"Password length should be greater than 6";
                          },
                          obscureText: true,
                          controller: passwordTextEditingController,
                          style: simpleTextStyle(),
                          decoration: textFieldInputDecoration('password')
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8,),
                Container(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                    child: Text('Forget Password?',style: simpleTextStyle(),),
                  ),
                ),
                SizedBox(height: 8,),
                GestureDetector(
                  onTap: (){
                    signIn();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xff007EF4),
                          const Color(0xff2A75BC),
                        ]
                      ),
                      borderRadius: BorderRadius.circular(30)
                    ),
                    child: Text('Sign In',style: mediumTextStyle(),),
                  ),
                ),
                SizedBox(height: 8,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Don't have an account? ", style: mediumTextStyle()),
                    GestureDetector(
                      onTap: (){
                        widget.toggle();
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Register now", style: TextStyle(
                            color : Colors.white,
                            fontSize: 17,
                          decoration: TextDecoration.underline
                        )),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 160,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
