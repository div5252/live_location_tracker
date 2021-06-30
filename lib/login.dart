import 'signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';  

class Login extends StatefulWidget {
  const Login({ Key? key }) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference collectionReference = FirebaseFirestore.instance.collection('users');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  

  late String _email, _password, _name;

  checkAuthentication() async
  {
    _auth.authStateChanges().listen((user) {
      if(user != null)
      {
        this.addData();
        Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
      }
    });
  }

  addData() async
  {
    DocumentSnapshot ds = await collectionReference.doc(_auth.currentUser!.uid).get(); 
    _name = ds['name'];
    // _email = ds['email'];
    SharedPreferences sharedpreferences = await SharedPreferences.getInstance();
    sharedpreferences.setString('name', _name);
    sharedpreferences.setString('email', _email);
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
  }

  login() async
  {
    if(_formKey.currentState!.validate())
    {
      _formKey.currentState!.save();
      try {
        await _auth.signInWithEmailAndPassword(email: _email, password: _password);
      }
      catch(e)
      {
        showError(e.toString());
      }
    }
  }

  showError(String errormessage)
  {
    showDialog(
      context: context, 
      builder: (BuildContext context)
      {
        return AlertDialog(
          title: Text('ERROR'),
          content: Text(errormessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            )
          ],
        );
      }
    );
  }

  navigateToSignUp() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
              child: Container(
          child: Column(
            children: <Widget>[
              SizedBox(height: 100.0),
              Container(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: TextFormField(
                          validator: (input) {
                            if(input!.isEmpty) 
                            {
                              return 'Enter Email';
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email)
                          ),
                          onSaved: (input) => _email = input!.trim()
                        ),
                      ),
                      Container(
                        child: TextFormField(
                          validator: (input) {
                            if(input!.length < 6) 
                            {
                              return 'Password has a minimum 6 characters';
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock)
                          ),
                          obscureText: true,
                          onSaved: (input) => _password = input!
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Padding(
                        padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
                        child: ElevatedButton(
                          onPressed: login, 
                          child: Text(
                            'LOGIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                child: Text('Create an Account'),
                onTap: navigateToSignUp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}