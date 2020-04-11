import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:map_controller/map_controller.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  void loadData() async {

    statefulMapController.addLine(name: "test", points: [
      for (final i in geojson["geometry"]["coordinates"]) LatLng(i[1], i[0])
    ],width: 5.0);
    statefulMapController.addMarker(marker: Marker(builder: (_) => Icon(Icons.location_on)) , name: "mark");
  }

  @override
  void initState() {
    mapController = MapController();
    statefulMapController = StatefulMapController(mapController: mapController);
    statefulMapController.onReady.then((_) => loadData());
    sub = statefulMapController.changeFeed.listen((change) => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        floatingActionButton: FloatingActionButton(onPressed: (){
          setState((){});
        }),
        body: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            center: LatLng(-18.9201000,47.5237000),
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
    sub.cancel();
    super.dispose();
  }
}
