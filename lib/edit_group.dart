import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'group_page.dart';
import 'add_members.dart';
import 'groups.dart';

class EditGroup extends StatefulWidget {
  final String id;

  const EditGroup({Key? key, required this.id}) : super(key: key);

  @override
  _EditGroupState createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {
  final CollectionReference groupReference = FirebaseFirestore.instance.collection('groups');
  List<String> _selectedNames = <String>[];
  bool isLoading = true;
  late String _groupname;
  late String _name;

  fetchData() async {
    SharedPreferences sharedpreferences = await SharedPreferences.getInstance();
    _name = sharedpreferences.getString('name')!;
    
    DocumentSnapshot ds = await groupReference.doc(widget.id).get();
    _groupname = ds['groupname'];

    setState(() {
      isLoading = false;
    });
  }

  initState() {
    super.initState();
    this.fetchData();
  }

  navigateToAddMembers() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddMembers(id: widget.id,)));
  }

  navigateToGroupPage() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => GroupPage(id: widget.id,)));
  }

  navigateToEditGroup() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditGroup(id: widget.id,)));
  }

  navigateToGroups() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Groups()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return navigateToGroupPage();
      },
      child: isLoading
      ? Center(child: CircularProgressIndicator())
      : Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.green,
            ),
            onPressed: navigateToGroupPage,
          ),
          title: Text(
            _groupname
          ),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: navigateToAddMembers,
                child: Text(
                  'Add members',
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
            SizedBox(height: 50),
            Container(
              child: StreamBuilder<DocumentSnapshot>(
                stream: groupReference.doc(widget.id).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    DocumentSnapshot<Object?> documents = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: (documents.data() as Map)['users'].length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(
                              (documents.data() as Map)['users'][index]
                            ),
                            trailing: (documents.data() as Map)['users'][index] != _name ?
                            IconButton(
                              icon: Icon(Icons.highlight_remove),
                              onPressed: () { 
                                removeMemberDialog((documents.data() as Map)['users'][index]);
                              }
                            ) : null,
                          ),
                        );
                      }
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 50),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: leaveGroupDialog,
                child: Text(
                  'Leave Group',
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
          ]
        ),
      ),
    );
  }

  removeMemberDialog(name) {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          content: Text(
            'Are you sure you want to remove $name?'
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "YES"
              ),
              onPressed: () {
                removeMember(name);
              },
            ),
            TextButton(
              child: Text(
                "NO"
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
        );
      }
    );
  }

  removeMember(name) async {
    await groupReference.doc(widget.id).get().then((value) {
      _selectedNames.addAll((value.data()! as Map)['users'].cast<String>());
    });
    removeMemberDB(name);
  }

  removeMemberDB(name) {
    try {
      _selectedNames.remove(name);
      Map<String, dynamic> data = {'users': _selectedNames};
      groupReference.doc(widget.id).update(data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Members removed'),
      ));
      _selectedNames.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to remove members'),
      ));
    }
    navigateToEditGroup();
  }

  leaveGroupDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            'Are you sure you want to leave the group?'
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "YES"
              ),
              onPressed: leaveGroup,
            ),
            TextButton(
              child: Text(
                "NO"
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
        );
      }
    );
  }

  leaveGroup() async {
    await groupReference.doc(widget.id).get().then((value) {
      _selectedNames.addAll((value.data()! as Map)['users'].cast<String>());
    });
    leaveGroupDB();
  }

  leaveGroupDB() {
    _selectedNames.remove(_name);
    Map<String, dynamic> data = {'users': _selectedNames};
    groupReference.doc(widget.id).update(data);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Left the group $_groupname'),
    ));
    _selectedNames.clear();

    navigateToGroups();
  }
}