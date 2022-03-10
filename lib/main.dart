import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'json_data_explorer.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Json Data Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  dynamic jsonContent;
  List<FlatJsonNodeModelState> nodes = [];

  @override
  void initState() {
    // https://awesomeopensource.com/project/jdorfman/awesome-json-datasets
    //loadJsonDataFrom('https://www.reddit.com/r/all.json');

    // Long list of Earth Meteorite Landings
    // loadJsonDataFrom('https://data.nasa.gov/resource/y77d-th95.json');

    // Earth Meteorite Landings
    // loadJsonDataFrom('https://data.nasa.gov/resource/y77d-th95.json');

    // Simple JSON
    // ISS current location
    //loadJsonDataFrom('http://api.open-notify.org/iss-now.json');

    // Medium JSON with array
    // Nobel prizes country.
    //loadJsonDataFrom('http://api.nobelprize.org/v1/country.json');

    // Large JSON
    // Pokemon
    //loadJsonDataFrom('https://pokeapi.co/api/v2/pokemon/?offset=0&limit=2000');

    // Australia ABC Local Stations.
    loadJsonDataFrom(
        'https://data.gov.au/geoserver/abc-local-stations/wfs?request=GetFeature&typeName=ckan_d534c0e9_a9bf_487b_ac8f_b7877a09d162&outputFormat=json');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test json widget"),
      ),
      body: SafeArea(
        child: JsonDataExplorer(
          nodes: nodes,
        ),
      ),
    );
  }

  Future loadJsonDataFrom(String url) async {
    final data = await http.read(Uri.parse(url));
    var decoded = json.decode(data);
    final builtNodes = buildJsonNodes(decoded);
    setState(() {
      nodes = builtNodes;
      jsonContent = decoded;
    });
  }
}
