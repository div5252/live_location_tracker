import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('users');

  late String _email, _password, _name;

  checkAuthentication() async {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        this.addData();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home()));
      }
    });
  }

  addData() async {
    Map<String, dynamic> data = {'name': _name, 'email': _email, 'signin mode': 'email'};
    await collectionReference.doc(_auth.currentUser!.uid.toString()).set(data);

    SharedPreferences sharedpreferences = await SharedPreferences.getInstance();
    sharedpreferences.setString('name', _name);
    sharedpreferences.setString('email', _email);
    sharedpreferences.setString('signin mode', 'email');
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
  }

  signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await _auth.createUserWithEmailAndPassword(
            email: _email, password: _password);
        await _auth.currentUser!.updateDisplayName(_name);
      } catch (e) {
        showError(e.toString());
      }
    }
  }

  showError(String errormessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height:40),
                        Container(
                          width:89.52,
                          height:61.72,
                          decoration: BoxDecoration(
                          color:Colors.transparent,
                          image: DecorationImage(image: AssetImage("assets/Logo.png"), fit: BoxFit.fill)),
                        ),
                        SizedBox(height:30),
                        Text(
                          'Create your',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                        SizedBox(height:8),
                        Text(
                          'Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height:60),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 328,
                          height: 56,
                          child: TextFormField(
                              validator: (input) {
                                if (input!.isEmpty) {
                                  return 'Enter Name';
                                }
                              },
                              decoration: InputDecoration(
                                  labelText: 'Name',
                                  suffixIcon: Icon(Icons.person)),
                              onSaved: (input) => _name = input!.trim()),
                        ),
                        Container( 
                          width: 328,
                          height: 56,
                          child: TextFormField(
                              validator: (input) {
                                if (input!.isEmpty) {
                                  return 'Enter Email';
                                }
                              },
                              decoration: InputDecoration(
                                  labelText: 'Email',
                                  suffixIcon: Icon(Icons.email)),
                              onSaved: (input) => _email = input!.trim()),
                        ),
                        Container(
                          width: 328,
                          height: 56,
                          child: TextFormField(
                              validator: (input) {
                                if (input!.length < 6) {
                                  return 'Provide minimum 6 characters';
                                }
                              },
                              decoration: InputDecoration(
                                  labelText: 'Password',
                                  suffixIcon: Icon(Icons.lock)),
                              obscureText: true,
                              onSaved: (input) => _password = input!),
                        ),
                        SizedBox(height: 90.0),
                        Container(
                          width: 307,
                          height:49,
                          child: ElevatedButton(
                            onPressed: signUp,
                            child: Text(
                              'REGISTER',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    side: BorderSide(color: Colors.black)),
                              ),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blueGrey[900]),
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
      ),
    );
  }
}
