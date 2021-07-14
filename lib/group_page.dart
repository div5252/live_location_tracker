import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';
import 'groups.dart';
import 'edit_group.dart';

class GroupPage extends StatefulWidget {
  final String id;

  const GroupPage({Key? key, required this.id}) : super(key: key);

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference groupReference =
      FirebaseFirestore.instance.collection('groups');

  BehaviorSubject<double> radius = BehaviorSubject();
  late Stream<List<DocumentSnapshot>> stream;
  double _value = 0.0;
  String _label = 'Adjust Radius';
  late Set<Marker> _markers = {};
  bool isLoading = true;
  late String _name;
  late double _latitude;
  late double _longitude;
  bool done = false;
  Location location = new Location();
  late String _groupname;

  onCreateMap(GoogleMapController mapController) {
    location.onLocationChanged.listen((LocationData currentLocation) async {
      double prevZoom = await mapController.getZoomLevel(); 
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          zoom: prevZoom,
        )),
      );
      GeoFirePoint myLocation = Geoflutterfire().point(
          latitude: currentLocation.latitude!,
          longitude: currentLocation.longitude!);
      addToDB(myLocation);
    });

    stream.listen((List<DocumentSnapshot> documentList) {
      updateMarkers(documentList);
    });
  }

  addToDB(myLocation) {
    groupReference
        .doc(widget.id)
        .collection('locations')
        .doc(_auth.currentUser!.uid)
        .set({'name': _name, 'position': myLocation.data});
  }

  changedRadius(value) {
    setState(() {
      _value = value;
      _label = '${_value.toInt().toString()} kms';
      _markers.clear();
    });
    radius.add(value);
  }

  updateMarkers(List<DocumentSnapshot> documentList) {
    setState(() {
      _markers.clear();
    });
    documentList.forEach((DocumentSnapshot document) {
      final GeoPoint point = document['position']['geopoint'];
      addMarker(point.latitude, point.longitude, document['name']);
    });
  }

  addMarker(double latitude, double longitude, String name) {
    _markers.add(Marker(
      markerId: MarkerId(name),
      position: LatLng(latitude, longitude),
      draggable: false,
      infoWindow: InfoWindow(
        title: name,
      ),
    ));
  }

  initStream() {
    GeoFirePoint center =
        Geoflutterfire().point(latitude: _latitude, longitude: _longitude);
    stream = radius.switchMap((rad) {
      return Geoflutterfire()
        .collection(
            collectionRef:
                groupReference.doc(widget.id).collection('locations'))
        .within(
          center: center,
          radius: rad,
          field: 'position',
          strictMode: true,
        );
      }
    );
  }

  fetchData() async {
    SharedPreferences sharedpreferences = await SharedPreferences.getInstance();
    _name = sharedpreferences.getString('name')!;

    DocumentSnapshot ds = await groupReference.doc(widget.id).get();
    _groupname = ds['groupname'];

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      _latitude = _locationData.latitude!;
      _longitude = _locationData.longitude!;
    });

    // 10000ms and 100m
    location.changeSettings(interval: 10000, distanceFilter: 100);

    initStream();
    setState(() {
      isLoading = false;
    });
  }

  navigateToGroups() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Groups()));
  }

  navigateToEditGroup() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditGroup(id: widget.id,)));
  }

  @override
  void initState() {
    super.initState();
    this.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
    onWillPop: () async {
      return navigateToGroups();
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
            onPressed: navigateToGroups,
          ),
          title: TextButton(
            onPressed: navigateToEditGroup,
            child: Text(
              _groupname,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                )
              ),
              height: 420,
              width: double.infinity,
              child: GoogleMap(
                onMapCreated: (controller) {
                  onCreateMap(controller);
                },
                myLocationEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: LatLng(_latitude, _longitude),
                  zoom: 12,
                ),
                markers: _markers,
              ),
            ),
            SizedBox(height:10),
            Container(
              width: 200,
              child: Slider(
                min: 0,
                max: 1000,
                divisions: 200,
                value: _value,
                label: _label,
                activeColor: Colors.blueGrey[900],
                inactiveColor: Colors.black.withOpacity(0.2),
                onChanged: (double value) {
                  changedRadius(value);
                },
              ),
            ),
            Text('Current Search Radius',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 18,
              ),
            ),
            Text('$_value Kms',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height:30),
            Container(
              width: 307,
              height:49,
              child: ElevatedButton(
                onPressed: navigateToEditGroup,
                child: Text(
                  'EDIT GROUP',
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
    );
  }
}