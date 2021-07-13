import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';  
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final CollectionReference collectionReference = FirebaseFirestore.instance.collection('users');
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken != null && googleAuth.accessToken != null) {
        final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

        final UserCredential user =
            await _auth.signInWithCredential(credential);


        
        Map<String, dynamic> data = {'name': Text(googleUser.displayName ?? ''), 'email': Text(googleUser.email)};
        collectionReference.doc(_auth.currentUser!.uid.toString()).set(data);
        // _email = ds['email'];
        SharedPreferences sharedpreferences = await SharedPreferences.getInstance();
        sharedpreferences.setString('name', googleUser.displayName??'');
        sharedpreferences.setString('email', googleUser.email);

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
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Positioned(
          top:0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 379,
            color: Colors.amber,
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
                SizedBox(height: 180,),
                Container(
                  width: 307,
                  height:49,
                  child: ElevatedButton(
                    onPressed: navigateToLogin,
                    child: Text(
                      'LOGIN',
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
                SizedBox(height: 21,),
                Container(
                  width: 307,
                  height:49,
                  child: ElevatedButton(
                    onPressed: navigateToRegister,
                    child: Text(
                      'REGISTER',
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
                SizedBox(height: 21,),
                Container(
                  width: 307,
                  height:49,
                  child: ElevatedButton(
                    onPressed: googleSignIn,
                    child: Text(
                      'Sign in with Google',
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


