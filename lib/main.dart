import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:map_controller/map_controller.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mayday',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Mayday'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MapController mapController;
  StatefulMapController statefulMapController;
  StreamSubscription<StatefulMapControllerStateChange> sub;
  SocketIO socketIO;
  List<LatLng> points = [];
  LatLng myPlace = LatLng(-18.9201000, 47.5237000);
  LatLng targetPlace;
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  Location location = new Location();
  bool isReady = false;
  bool isFollowing = false;
  Timer updater;

  Future<void> initialiseLocation() async {
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
  }

  @override
  void initState() {
    initialiseLocation();
    mapController = MapController();
    statefulMapController = StatefulMapController(mapController: mapController);
    statefulMapController.onReady.then((_) => isReady = true);
    sub = statefulMapController.changeFeed.listen((change) => setState(() {}));
    updateMyPlace();
    socketInit();
    super.initState();
  }

  void updateMyPlace() {
    updater = Timer.periodic(Duration(minutes: 1), (timer) async {
      _locationData = await location.getLocation();
      myPlace = LatLng(_locationData.latitude, _locationData.longitude);
      await statefulMapController.centerOnPoint(myPlace);
      try {
        await statefulMapController.removeMarker(name: "currentPlace");
      } catch (e) {}
      await statefulMapController.addMarker(
          marker: Marker(
              builder: (_) => Icon(Icons.location_on, color: Colors.teal),
              point: myPlace
              ),
          name: "currentPlace");
      if (isFollowing) {
        points = await getPoints(d: myPlace, f: targetPlace);
        try {
          await statefulMapController.removeLine("route");
        } catch (e) {}
        await statefulMapController.addLine(name: "route", points: points);
      }
    });
  }
  void startFollow(LatLng target){
    isFollowing = true;
    targetPlace = target;
  }

  Future<List<LatLng>> getPoints({LatLng d, LatLng f}) async {
    double dlo = d.longitude;
    double dla = d.latitude;
    double flo = f.longitude;
    double fla = f.latitude;
    http.Response rep = await http.get(
        "https://mayday-kaody.herokuapp.com/api/directions?dlo=$dlo&dla=$dla&flo=$flo&fla=$fla");

    if (rep.statusCode == 200) {
      List data = json.decode(rep.body)["points"];
      List<LatLng> res = [];
      for (List pt in data) {
        res.add(LatLng(pt[0], pt[1]));
      }
      return res;
    } else {
      return [];
    }
  }

  void socketInit() {
    socketIO = SocketIOManager().createSocketIO(
        "http://mayday-kaody.herokuapp.com", "/",
        socketStatusCallback: () {});
    socketIO.init();
    socketIO.subscribe("distress", () {
      var data = http.get("http://mayday-kaody.herokuapp.com/api/distresss");
    });
    socketIO.connect();
    socketIO.subscribe("distress", () {
      var data = http.get("http://mayday-kaody.herokuapp.com/api/distresss");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Color.fromARGB(255, 10, 176, 153),
        ),
        body: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            center: myPlace,
            zoom: 13.0,
          ),
          layers: [
            TileLayerOptions(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c']),
            MarkerLayerOptions(markers: statefulMapController.markers),
            PolylineLayerOptions(polylines: statefulMapController.lines),
            PolygonLayerOptions(polygons: statefulMapController.polygons)
          ],
        ));
  }

  @override
  void dispose() {
    updater.cancel();
    sub.cancel();
    super.dispose();
  }
}
