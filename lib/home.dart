import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile.dart';
import 'welcome.dart';
import 'groups.dart';

class Home extends StatefulWidget {
  const Home({ Key? key }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference collectionReference = FirebaseFirestore.instance.collection('users');
  User? user;
  bool isloggedin = false;
  
  checkAuthentication() async {
    _auth.authStateChanges().listen((user) {
      if(user == null)
      {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Welcome()));
      }
    });
  }

  getUser() async {
    User? firebaseUser = _auth.currentUser;
    await firebaseUser?.reload();
    firebaseUser = _auth.currentUser;

    if(firebaseUser != null) 
    {
      setState(() {
        this.user = firebaseUser;
        this.isloggedin = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
    this.getUser();
  }
  
  navigateToProfile() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
  }

  navigateToGroups() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Groups()));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Positioned(
          top:0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 406,
            decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/WelcomeBGM.png"), fit: BoxFit.cover)),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height - 426,
          child: Container(
            height: 426,
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
                SizedBox(height: 200,),
                Container(
                  width: 307,
                  height:49,
                  child: ElevatedButton(
                    onPressed: navigateToProfile,
                    child: Text(
                      'PROFILE',
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
                SizedBox(height: 40,),
                Container(
                  width: 307,
                  height:49,
                  child: ElevatedButton(
                    onPressed: navigateToGroups,
                    child: Text(
                      'GROUPS',
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
    );
  }
}
