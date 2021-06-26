import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({ Key? key }) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference collectionReference = FirebaseFirestore.instance.collection('users');

  late String _email, _name;

  Future<void> fetchData() async {  print(_auth.currentUser!.uid);
    DocumentSnapshot ds = await collectionReference.doc(_auth.currentUser!.uid).get(); 
    _name = ds['name'];
    _email = ds['email'];
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