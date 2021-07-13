import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile.dart';
import 'home.dart';
import 'package:google_sign_in/google_sign_in.dart';  
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('users');
  late String _email, _name, _mode;

  Future<void> fetchData() async {
    SharedPreferences sharedpreferences = await SharedPreferences.getInstance();
    _name = sharedpreferences.getString('name')!;
    _email = sharedpreferences.getString('email')!;
    _mode = sharedpreferences.getString('signin mode')!;
  }

  @override
  void initState() {
    super.initState();
  }

  signOut() async {
    DocumentSnapshot ds = await collectionReference.doc(_auth.currentUser!.uid.toString()).get();
    if (ds['signin mode'] == 'google') {
      GoogleSignIn _googleSignIn =
          GoogleSignIn(); // here object of google signIn created
      _googleSignIn.disconnect();
    }
    _auth.signOut();
  }

  navigateToHome() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  navigateToEditProfile() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => EditProfile()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return navigateToHome();
      },
      child: Scaffold(
        appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: Colors.white,
        ),
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top:0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 436,
                color: Colors.amber,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height - 456,
              child: Container(
                height: 456,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft:Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  color: Colors.grey[200],
                ),
                child: Column(
                  children: [
                    SizedBox(height: 50,),
                    FutureBuilder(
                      future: fetchData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return Text("Loading");
                        }
                        return Column(
                          children: <Widget>[
                            Container(
                              child: Text(
                                "$_name",
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Container(
                              child: Text(
                                "$_email",
                                style: TextStyle(
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    SizedBox(
                      height: 80.0,
                    ),
                    FutureBuilder(
                      future: fetchData(),
                      builder: (context,snapshot) {
                        if (snapshot.connectionState != ConnectionState.done||_mode=='google') {
                          return SizedBox(height: 1,);
                        }
                        else return Container(
                          width: 307,
                          height:49,
                          child: ElevatedButton(
                            onPressed: navigateToEditProfile,
                            child: Text(
                              'EDIT PROFILE',
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
                        );
                      }
                    ),
                    SizedBox(height: 40,),
                    Container(
                      width: 307,
                      height:49,
                      child: ElevatedButton(
                        onPressed: signOut,
                        child: Text(
                          'SIGN OUT',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
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
                              MaterialStateProperty.all(Colors.grey[200]),
                        ),
                      ),
                    ),
                    
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
