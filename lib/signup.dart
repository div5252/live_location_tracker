import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';

class SignUp extends StatefulWidget {
  const SignUp({ Key? key }) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String _email, _password, _name;

  checkAuthentication() async {
    _auth.authStateChanges().listen((user) {
      if(user != null)
      {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
  }

  signUp() async {
    if(_formKey.currentState!.validate())
    {
      _formKey.currentState!.save();

      try {
        await _auth.createUserWithEmailAndPassword(email: _email, password: _password);
        await _auth.currentUser!.updateDisplayName(_name);
      }
      catch(e) {
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
                              return 'Enter Name';
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.person)
                          ),
                          onSaved: (input) => _name = input!.trim()
                        ),
                      ),
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
                              return 'Provide minimum 6 characters';
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
                          onPressed: signUp, 
                          child: Text(
                            'SignUp',
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
            ],
          ),
        ),
      ),
    );
  }
}