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
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.green,
            ),
            onPressed: navigateToProfile,
          ),
        ),
        body: Container(
          padding: EdgeInsets.only(left: 16, top: 25, right: 16),
          child: ListView(
            children: [
              Text(
                "Edit Profile",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              SizedBox(height: 35),
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
                          TextFormField(
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
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              hintText: "$_name",
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(height: 35),
                          TextFormField(
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
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              hintText: "$_email",
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(height: 35),
                        ],
                      ),
                    );
                  }),
              SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  OutlinedButton(
                    onPressed: navigateToEditProfile,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "CANCEL",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: editData,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      "SAVE",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              // Add reset password
            ],
          ),
        ),
      ),
    );
  }
}
