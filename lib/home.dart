import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'profile.dart';
import 'welcome.dart';
import 'groups.dart';

class Home extends StatefulWidget {
  const Home({ Key? key }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference collectionReference = FirebaseFirestore.instance.collection('users');
  late GoogleMapController mapController;
  User? user;
  bool isloggedin = false;
  bool mapToggle = false;
  var currentLocation;
  late Set<Marker> _markers = {};
  
  checkAuthentication() async {
    _auth.authStateChanges().listen((user) {
      if(user == null)
      {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Welcome()));
      }
    });
  }

  getUser() async {
    User? firebaseUser = _auth.currentUser;
    await firebaseUser?.reload();
    firebaseUser = _auth.currentUser;

    if(firebaseUser != null) 
    {
      setState(() {
        this.user = firebaseUser;
        this.isloggedin = true;
      });
    }
  }

  getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((currloc) {
      setState(() {
        currentLocation = currloc;
        Map<String, dynamic> data = {'location': {'latitude': currloc.latitude, 'longitude': currloc.longitude}};
        collectionReference.doc(_auth.currentUser!.uid.toString()).update(data);
        mapToggle = true;
      });
    });
  }

  setMarkers() async {
    DocumentSnapshot ds = await collectionReference.doc(_auth.currentUser!.uid.toString()).get();
    setState(() {
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId(ds['name']),
        position: LatLng(ds['location']['latitude'], ds['location']['longitude']),
        draggable: false,
      ));
      //mapToggle = true;
    });
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
    this.getUser();
    this.getLocation();
    this.setMarkers();
  }
  
  navigateToProfile() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
  }

  navigateToGroups() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Groups()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: !isloggedin ? CircularProgressIndicator() :
        Column(
          children: <Widget>[
            SizedBox(height: 100.0),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: navigateToProfile,
                child: Text(
                  'Profile',
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
            SizedBox(height: 30.0),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: navigateToGroups,
                child: Text(
                  'Groups',
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
            SizedBox(height: 30.0,),
            Stack(
              children: <Widget>[
                Container(
                  height: 500,
                  width: double.infinity,
                  child: mapToggle ?
                  GoogleMap(
                    onMapCreated: (controller) {
                      mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(currentLocation.latitude, currentLocation.longitude), 
                      zoom: 15.0,
                    ),
                    markers: _markers,
                  ):
                  Center(child: Text(
                    'Loading Maps.. Please wait',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
