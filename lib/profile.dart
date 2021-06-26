import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({ Key? key }) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String _email, _name;

  Future<void> fetchData() async {  
    SharedPreferences sharedpreferences = await SharedPreferences.getInstance();
    _name = sharedpreferences.getString('name')!;
    _email = sharedpreferences.getString('email')!;
  }

  @override
  void initState() {
    super.initState();
  }
  
  signOut() async {
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            SizedBox(height: 40.0,),
            FutureBuilder(
              future: fetchData(),
              builder: (context, snapshot) {
                if(snapshot.connectionState != ConnectionState.done) {
                  return Text(
                    "Loading"
                  );
                }
                return Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        "Name: $_name",
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.0),
                    Container(
                      child: Text(
                        "Email: $_email",
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ],
                );
              }
            ),
            SizedBox(height: 40.0,),
            Padding(
              padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
              child: ElevatedButton(
                onPressed: signOut, 
                child: Text(
                  'SIGN OUT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.orange),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}