import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('users');

  late String _email, _name, newemail, newname;

  Future<void> fetchData() async {
    SharedPreferences sharedpreferences = await SharedPreferences.getInstance();
    _name = sharedpreferences.getString('name')!;
    _email = sharedpreferences.getString('email')!;
  }

  editData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (newemail != _email) {
        _auth.currentUser!.updateEmail(newemail).then((_) {
          updateData();
        }).catchError((e) {
          showError(e.toString());
        });
      } else if (newname != _name) {
        updateData();
      }

      navigateToEditProfile();
    }
  }

  updateData() async {
    Map<String, dynamic> data = {'name': newname, 'email': newemail};
    collectionReference.doc(_auth.currentUser!.uid.toString()).update(data);

    SharedPreferences sharedpreferences = await SharedPreferences.getInstance();
    sharedpreferences.setString('name', newname);
    sharedpreferences.setString('email', newemail);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Profile Updated Successfully'),
    ));

    navigateToEditProfile();
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
        });
  }

  navigateToProfile() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
  }

  navigateToEditProfile() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => EditProfile()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return navigateToProfile();
      },
      child: Scaffold(
        appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        ),
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top:0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 340,
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
                      return Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              width: 328,
                              height: 56,
                              child: TextFormField(
                                onSaved: (input) {
                                  newname = _name;
                                  if (input!.isNotEmpty) {
                                    newname = input.trim();
                                  }
                                },
                                validator: null,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(bottom: 3),
                                  labelText: "Name",
                                  suffixIcon: Icon(Icons.person),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  hintText: "$_name",
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              width: 328,
                              height: 56,
                              child: TextFormField(
                                onSaved: (input) {  
                                  newemail = _email;
                                  if (input!.isNotEmpty) {
                                    newemail = input.trim();
                                  }
                                },
                                validator: null,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(bottom: 3),
                                  labelText: "Email",
                                  suffixIcon: Icon(Icons.email),
                                  
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  hintText: "$_email",
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 35),
                          ],
                        ),
                      );
                    }),
                    
                    Container(
                      width: 307,
                      height:49,
                      child: ElevatedButton(
                        onPressed: editData,
                        child: Text(
                          'SAVE',
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
                    SizedBox(height: 30,),
                    Container(
                      width: 307,
                      height:49,
                      child: ElevatedButton(
                        onPressed: navigateToProfile,
                        child: Text(
                          'CANCEL',
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
