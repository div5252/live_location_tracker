import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile.dart';
import 'welcome.dart';

class Home extends StatefulWidget {
  const Home({ Key? key }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: !isloggedin ? CircularProgressIndicator() :
        Column(
          children: <Widget>[
            SizedBox(height: 100.0),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: navigateToProfile,
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.orange),
                ),
              ),
            ),
            SizedBox(height: 30.0),
            Container(
              child: Text(
                "Hello ${user?.displayName}, you are logged in as ${user?.email}",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
