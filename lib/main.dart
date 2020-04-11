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
  String json = '''
  
  {
  "type": "LineString",
  "crs": {
    "type": "name",
    "properties": {
      "name": "urn:ogc:def:crs:OGC:1.3:CRS84"
    }
  },
  "coordinates":
  [
[47.524575, -18.943554]
,[47.524490, -18.943625]
,[47.524367, -18.943648]
,[47.524310, -18.943658]
,[47.524152, -18.943656]
,[47.524058, -18.943633]
,[47.524037, -18.943610]
,[47.524022, -18.943589]
,[47.523825, -18.943321]
,[47.523756, -18.943233]
,[47.523645, -18.943094]
,[47.523499, -18.942882]
,[47.523396, -18.942843]
,[47.523293, -18.942884]
,[47.523233, -18.943053]
,[47.523353, -18.943167]
,[47.523477, -18.943279]
,[47.523756, -18.943532]
,[47.523962, -18.943686]
,[47.524117, -18.943881]
,[47.524193, -18.944020]
,[47.524225, -18.944079]
,[47.524237, -18.944100]
,[47.524357, -18.944352]
,[47.524463, -18.944603]
,[47.524563, -18.944604]
,[47.524979, -18.944619]
,[47.525221, -18.944646]
,[47.525434, -18.944708]
,[47.528626, -18.946096]
,[47.530086, -18.946851]
,[47.530893, -18.947160]
,[47.531897, -18.947428]
,[47.532918, -18.947590]
,[47.532987, -18.947557]
,[47.533018, -18.947481]
,[47.533030, -18.947452]
,[47.533066, -18.947347]
,[47.533098, -18.947257]
,[47.533364, -18.947070]
,[47.533639, -18.946551]
,[47.533730, -18.946403]
  ],  "properties": {
    "distance": "1.547792",
    "description": "To enable simple instructions add: 'instructions=1' as parameter to the URL",
    "traveltime": "133"
    }
}

  ''';
  // Map geojson = {
  //   "type": "Feature",
  //   "properties": {},
  //   "geometry": {
  //     "type": "Line",
  //     "coordinates": [
  //       [47.524609, -18.943591],
  //       [47.524596, -18.9436],
  //       [47.524508, -18.943652],
  //       [47.524447, -18.943692],
  //       [47.524342, -18.943767],
  //       [47.524289, -18.943807],
  //       [47.524208, -18.943861],
  //       [47.524133, -18.943904],
  //       [47.524175, -18.943972],
  //       [47.524408, -18.944461],
  //       [47.524442, -18.944538],
  //       [47.524501, -18.944534],
  //       [47.524571, -18.944537],
  //       [47.524666, -18.94455],
  //       [47.524707, -18.944562],
  //       [47.524843, -18.94457],
  //       [47.525096, -18.944612],
  //       [47.525434, -18.944708],
  //       [47.526004, -18.944941],
  //       [47.528626, -18.946096],
  //       [47.530086, -18.946851],
  //       [47.530641, -18.947072],
  //       [47.53121, -18.947253],
  //       [47.531882, -18.947411],
  //       [47.532816, -18.947566],
  //       [47.532918, -18.947558],
  //       [47.532927, -18.947553],
  //       [47.532939, -18.947531],
  //       [47.53297, -18.947444],
  //       [47.532984, -18.947399],
  //       [47.532997, -18.947371],
  //       [47.533018, -18.947326],
  //       [47.53304, -18.94728],
  //       [47.533074, -18.947245],
  //       [47.533234, -18.947159],
  //       [47.533327, -18.947077],
  //       [47.533623, -18.946527],
  //       [47.533718, -18.946396]
  //     ]
  //   }
  // };
  void loadData() async {
    print("Loading geojson data");
    statefulMapController.fromGeoJson(json);
    // statefulMapController.addLine(name: "test", points: [
    //   for (final i in geojson["geometry"]["coordinates"]) LatLng(i[1], i[0])
    // ],width: 5.0);
    // statefulMapController.addMarker(marker: Marker(builder: (_) => Icon(Icons.location_on)) , name: "mark");
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
            center: LatLng(47.5237000,-18.9201000),
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
