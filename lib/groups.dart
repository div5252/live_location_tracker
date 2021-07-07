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
      appBar: AppBar(
        title: Text('Choose a group'),
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
                        child: ListTile(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => GroupPage(id: documents[index].id)));
                          },
                          title: Text(
                            documents[index]['groupname']
                          ),
                          subtitle: Text(
                            usersList(documents[index]['users']),
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
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToSearchGroups,
        child: Icon(
          Icons.add,
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