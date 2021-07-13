import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_group.dart';

class AddMembers extends StatefulWidget {
  final String id;
  const AddMembers({Key? key, required this.id}) : super(key: key);

  @override
  _AddMembersState createState() => _AddMembersState();
}

class _AddMembersState extends State<AddMembers> {
  final CollectionReference userReference = FirebaseFirestore.instance.collection('users');
  final CollectionReference groupReference = FirebaseFirestore.instance.collection('groups');

  bool isLoading = true;
  late String _name;
  List<String> _names = <String>[];
  List<String> _selectedNames = <String>[];
  Map<String, bool> _isSelected = <String, bool>{};
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

  navigateToEditGroup() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditGroup(id: widget.id)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return navigateToEditGroup();
      },
      child: isLoading
      ? Center(child: CircularProgressIndicator())
      : Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: navigateToEditGroup,
          ),
          title: hasSearched ? _buildSearchField() : Text("Search Members"),
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
                children: _selectedNames
                  .map((item) => _buildChip(item))
                  .toList()
                  .cast<Widget>(),
              ),
            ),
            Divider(
              thickness: 1.0,
            ),
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
                  tileColor:
                      _isSelected[_names[index]]! ? Colors.grey[300] : null,
                  trailing: _isSelected[_names[index]]!
                  ? Icon(Icons.check)
                  : null,
                );
              },
            ),
          ],
        ),
        floatingActionButton: Container(
          width: 63,
          height: 63,
          child: FloatingActionButton(
            onPressed: addMembers,
            backgroundColor: Colors.blueGrey[900],
            child: Icon(
              Icons.check,
              size: 31,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return new TextField(
      autofocus: true,
      style: TextStyle(
        color: Colors.black,
        fontSize: 16.0,
      ),
      onChanged: (text) {
        _names.clear();
        userReference.where('name', isEqualTo: text).get().then((snapshot) {
          setState(() {
            snapshot.docs.forEach((element) {
              if (element['name'] != _name && !_names.contains(element['name'])) {
                _names.add(element['name']);
                if (_selectedNames.contains(element['name'])) {
                  _isSelected[element['name']] = true;
                } else {
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
      } else {
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

  Widget _buildChip(String label) {
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
        size: 20,
        color: Colors.white,
      ),
      onDeleted: () => deleteSelection(label),
      backgroundColor: Colors.blueGrey[900],
      elevation: 6.0,
      shadowColor: Colors.grey[60],
      padding: EdgeInsets.all(8.0),
    );
  }

  addMembers() async {
    if (_selectedNames.length != 0) {
      await groupReference.doc(widget.id).get().then((value) {
        _selectedNames.addAll((value.data()! as Map)['users'].cast<String>());
      });
      addMembersDB();
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Add atleast one member!'),
      ));
    }
  }

  addMembersDB() {
    try {
      Map<String, dynamic> data = {'users': _selectedNames};
      groupReference.doc(widget.id).update(data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Members added'),
      ));
      _selectedNames.clear();
      _isSelected.clear();
    } 
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add members'),
      ));
    }
    navigateToEditGroup();
  }
}