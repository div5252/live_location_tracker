import 'package:flutter/material.dart';
import 'add_groups.dart';

class Groups extends StatefulWidget {
  const Groups({ Key? key }) : super(key: key);

  @override
  _GroupsState createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  
  navigateToSearchGroups() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddGroups()));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a group'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            
          ],
        ),
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