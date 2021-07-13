import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_groups.dart';
import 'group_page.dart';

class Groups extends StatefulWidget {
  const Groups({Key? key}) : super(key: key);

  @override
  _GroupsState createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {

  final CollectionReference groupReference = FirebaseFirestore.instance.collection('groups');
  
  bool isLoading = true;
  late String _name;
  
  navigateToSearchGroups() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddGroups()));
  }

  fetchData() async {
    SharedPreferences sharedpreferences = await SharedPreferences.getInstance();
    _name = sharedpreferences.getString('name')!;
    setState(() {
      isLoading = false;
    });
  }

  initState() {
    super.initState();
    this.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Center(child: CircularProgressIndicator()) 
    : Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Choose a group'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: <Widget> [
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: groupReference.where('users', arrayContains: _name).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                else {
                  List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      return Card(
                        borderOnForeground: false,
                        color: Colors.grey[100],
                        child: ListTile(
                          hoverColor: Colors.grey[200],
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => GroupPage(id: documents[index].id)));
                          },
                          title: Text(
                            documents[index]['groupname'],
                            style: TextStyle(fontSize: 16,),
                          ),
                          subtitle: Text(
                            usersList(documents[index]['users']),
                            style: TextStyle(fontSize: 14,),
                          ),
                        ),
                      );
                    }
                  );
                }
              },
            ),
          ),
        ]
      ),
      floatingActionButton: Container(
        height:63,
        width:63,
        child: FloatingActionButton(
          backgroundColor: Colors.blueGrey[900],
          onPressed: navigateToSearchGroups,
          child: Icon(
            Icons.add,
            size: 31,
          ),
        ),
      ),
    );
  }
}

String usersList(List<dynamic> users) {
  String s = users[0];
  for (int i = 1; i < users.length; i++) {
    s = s + ', ' + users[i];
  }
  return s;
}