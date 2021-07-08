import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_members.dart';

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
  late String _name;

  navigateToAddMembers() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddMembers(id: widget.id,)));
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
    return isLoading
    ? Center(child: CircularProgressIndicator())
    : Scaffold(
      appBar: AppBar(
        title: Text('Edit group'),
      ),
      body: Column(
        children: <Widget>[
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
                          trailing: IconButton(
                            icon: Icon(Icons.highlight_remove),
                            onPressed: () { 
                              removeMember((documents.data() as Map)['users'][index]);
                            }
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
        onPressed: navigateToAddMembers,
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }

  removeMember(name) {
    groupReference.doc(widget.id).get().then((value) {
      _selectedNames.addAll((value.data()! as Map)['users'].cast<String>());
    });
    
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
  }
}