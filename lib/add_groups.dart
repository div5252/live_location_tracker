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
    return WillPopScope(
      onWillPop: () async {
        return navigateToGroups();
      },
      child: isLoading ? Center(child: CircularProgressIndicator()) 
      : Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
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
            SizedBox(height:15),
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
        floatingActionButton: Container(
          width: 63,
          height: 63,
          child: FloatingActionButton(
            onPressed: makeGroup,
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

  makeGroup() {
    if (_selectedNames.length != 0) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            insetPadding: EdgeInsets.all(0),
            backgroundColor: Colors.transparent,
            child: Stack(
              overflow: Overflow.visible,
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Positioned(
                  top:180,
                  child: Container(
                    height: 505,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                        color: Colors.grey[200],
                      ),
                    child:Column(
                      children: [
                        SizedBox(height:50),
                        Container(
                          width: 328,
                          height: 56,
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
                        SizedBox(height:70),
                        Container(
                          width: 307,
                          height:49,
                          child: ElevatedButton(
                            onPressed: addGroupToDB,
                            child: Text(
                              'CREATE GROUP',
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
                      ],
                    )
                  ),
                ),
              ],
            )
          );
          /*return Dialog(
            backgroundColor: Colors.transparent,
            child: Column(
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
          );*/
        }
      );
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Add atleast one member!'),
      ));
    }
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
        _selectedNames.clear();
        _isSelected.clear();
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