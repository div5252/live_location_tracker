import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'groups.dart';

class AddGroups extends StatefulWidget {
  const AddGroups({ Key? key }) : super(key: key);

  @override
  _AddGroupsState createState() => _AddGroupsState();
}

class _AddGroupsState extends State<AddGroups> {
  
  final CollectionReference userReference = FirebaseFirestore.instance.collection('users');
  final CollectionReference groupReference = FirebaseFirestore.instance.collection('groups');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool isLoading = true;
  late String _name;
  late String _groupName;
  List<String> _names = <String>[];
  List<String> _selectedNames = <String>[];
  Map<String, bool> _isSelected = <String, bool> {};
  bool hasSearched = false;

  fetchData() async {
    SharedPreferences sharedpreferences = await SharedPreferences.getInstance();
    _name = sharedpreferences.getString('name')!;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    this.fetchData();
  }
  
  navigateToGroups() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Groups()));
  }
  
  @override
  Widget build(BuildContext context) {
    return isLoading ? Center(child: CircularProgressIndicator()) 
    : Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.green,
          ),
          onPressed: navigateToGroups,
        ),
        title: hasSearched ? _buildSearchField()
        : Text(
          "Create group"
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
            ),
            onPressed: () {
              setState(() {
                hasSearched = true;
              });
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: _selectedNames.map((item) => _buildChip(item))
              .toList()
              .cast<Widget>(),
            ),
          ),
          Divider(thickness: 1.0,),
          ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: _names.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  changeSelection(index);
                },
                title: Text(
                  _names[index],
                ),
                tileColor: _isSelected[_names[index]]! ? Colors.grey : null,
                trailing: _isSelected[_names[index]]! ? Icon(
                  Icons.check
                ) : null,
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: makeGroup,
        child: Icon(
          Icons.check,
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return new TextField(
      autofocus: true,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
      ),
      onChanged: (text) {
        _names.clear();
        userReference.where('name', isEqualTo: text).get().then((snapshot) {
          setState(() {
            snapshot.docs.forEach((element) {
              if (element['name'] != _name && !_names.contains(element['name'])) {
                _names.add(element['name']);
                if (_selectedNames.contains(element['name']))
                {
                  _isSelected[element['name']] = true;
                }
                else {
                  _isSelected[element['name']] = false;
                }
              }
            });
          });
        });
      },
    );
  }

  changeSelection(int index) {
    setState(() {
      if (_selectedNames.contains(_names[index])) {
        _isSelected[_names[index]] = false;
        _selectedNames.remove(_names[index]);
      }
      else {
        _isSelected[_names[index]] = true;
        _selectedNames.add(_names[index]);
      }
    });
  }

  deleteSelection(String label) {
    setState(() {
      _isSelected[label] = false;
      _selectedNames.remove(label);
    });
  }

  Widget _buildChip (String label) {
    return Chip(
      labelPadding: EdgeInsets.all(2.0),
      avatar: CircleAvatar(
        backgroundColor: Colors.black,
        child: Text(
          label[0].toUpperCase(),
        ),
      ),
      label: Text(
        label,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      deleteIcon: Icon(
        Icons.close,
      ),
      onDeleted: () => deleteSelection(label),
      backgroundColor: Colors.red,
      elevation: 6.0,
      shadowColor: Colors.grey[60],
      padding: EdgeInsets.all(8.0),
    );
  }

  makeGroup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: TextFormField(
                        validator: (input) {
                          if(input!.isEmpty) {
                            return 'Enter Group Name';
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Group Name',
                          prefixIcon: Icon(Icons.group)
                        ),
                        onSaved: (input) {
                          _groupName = input!.trim();
                        },
                      ),
                    ),
                    SizedBox(height: 30.0),
                    Padding(
                      padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
                      child: ElevatedButton(
                        onPressed: addGroupToDB,
                        child: Text(
                          'Create Group',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  addGroupToDB() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        _selectedNames.add(_name);
        Map<String, dynamic> data = {'groupname': _groupName, 'users': _selectedNames};
        groupReference.add(data);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Group Created'),
        ));
        navigateToGroups();
      }
      catch(e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to create group'),
        ));
      }
    }
  }
}