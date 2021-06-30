import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home.dart';
import 'login.dart';
import 'signup.dart';

class Welcome extends StatefulWidget {
  const Welcome({ Key? key }) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {

  navigateToLogin() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
  }
  navigateToRegister() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
  }

  
  Future<UserCredential> googleSignIn() async {
    GoogleSignIn _googleSignIn = GoogleSignIn(); // here object of google signIn created
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken != null && googleAuth.accessToken != null) {
        final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

        final UserCredential user =
            await _auth.signInWithCredential(credential);

        await Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));

        return user;
      } else {
        throw StateError('Missing Google Auth Token');
      }
    } else
      throw StateError('Sign in Aborted');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            SizedBox(height: 100.0),
            RichText(
              text: TextSpan(
                text: 'Welcome to Live Location Tracker',
                style: TextStyle(
                  fontSize: 25.0, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.black,
                ),
              )
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 30.0, right: 30.0),
                  child: ElevatedButton(
                    onPressed: navigateToLogin,
                    child: Text(
                      'LOGIN',
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
                SizedBox(width: 5.0),
                Padding(
                  padding: EdgeInsets.only(left: 30.0, right: 30.0),
                  child: ElevatedButton(
                    onPressed: navigateToRegister,
                    child: Text(
                      'REGISTER',
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
              ],
            ),
            SizedBox(height: 20.0,),
            SignInButton(
              Buttons.Google,
              text: "Sign up with Google",
              onPressed: googleSignIn,
            )
          ],
        ),
      ),
    );
  }
}


