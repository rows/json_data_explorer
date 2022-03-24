import 'dart:convert';

import 'package:data_explorer/data_explorer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

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

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Data Explorer"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Small JSON',
            style: Theme.of(context).textTheme.headline6,
          ),
          const _OpenJsonButton(
            title: 'ISS current location',
            url: 'http://api.open-notify.org/iss-now.json',
            padding: EdgeInsets.symmetric(vertical: 8.0),
          ),
          Text(
            'Medium JSON',
            style: Theme.of(context).textTheme.headline6,
          ),
          const _OpenJsonButton(
            title: 'Nobel prizes country',
            url: 'http://api.nobelprize.org/v1/country.json',
            padding: EdgeInsets.symmetric(vertical: 8.0),
          ),
          const _OpenJsonButton(
            title: 'Australia ABC Local Stations',
            url:
                'https://data.gov.au/geoserver/abc-local-stations/wfs?request=GetFeature&typeName=ckan_d534c0e9_a9bf_487b_ac8f_b7877a09d162&outputFormat=json',
          ),
          Text(
            'Large JSON',
            style: Theme.of(context).textTheme.headline6,
          ),
          const _OpenJsonButton(
            title: 'Pokémon',
            url: 'https://pokeapi.co/api/v2/pokemon/?offset=0&limit=2000',
            padding: EdgeInsets.symmetric(vertical: 8.0),
          ),
          const _OpenJsonButton(
            title: 'Earth Meteorite Landings',
            url: 'https://data.nasa.gov/resource/y77d-th95.json',
          ),
          const _OpenJsonButton(
            title: 'Reddit r/all',
            url: 'https://www.reddit.com/r/all.json',
          ),
          Text(
            'Exploding JSON',
            style: Theme.of(context).textTheme.headline6,
          ),
          const _OpenJsonButton(
            title: '25MB GitHub Json',
            url:
                'https://raw.githubusercontent.com/json-iterator/test-data/master/large-file.json',
            padding: EdgeInsets.only(top: 8.0, bottom: 32.0),
          ),
          Text(
            'More datasets at https://awesomeopensource.com/project/jdorfman/awesome-json-datasets',
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
    );
  }
}

class DataExplorerPage extends StatefulWidget {
  final String jsonUrl;
  final String title;

  const DataExplorerPage({
    Key? key,
    required this.jsonUrl,
    required this.title,
  }) : super(key: key);

  @override
  _DataExplorerPageState createState() => _DataExplorerPageState();
}

class _DataExplorerPageState extends State<DataExplorerPage> {
  final searchController = TextEditingController();
  final DataExplorerStore store = DataExplorerStore();

  @override
  void initState() {
    loadJsonDataFrom(widget.jsonUrl);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: ChangeNotifierProvider.value(
          value: store,
          child: Consumer<DataExplorerStore>(
            builder: (context, state, child) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (term) => state.search(term),
                        maxLines: 1,
                        decoration: const InputDecoration(
                          hintText: 'Search',
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    if (state.searchResults.isNotEmpty)
                      Text(
                          '${state.searchNodeFocusIndex + 1} of ${state.searchResults.length}'),
                    if (state.searchResults.isNotEmpty)
                      IconButton(
                        onPressed: () => store.focusPreviousSearchResult(),
                        icon: const Icon(Icons.arrow_drop_up),
                      ),
                    if (state.searchResults.isNotEmpty)
                      IconButton(
                        onPressed: () => store.focusNextSearchResult(),
                        icon: const Icon(Icons.arrow_drop_down),
                      ),
                  ],
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed:
                          state.areAllExpanded() ? null : state.expandAll,
                      child: const Text('Expand All'),
                    ),
                    const SizedBox(
                      width: 8.0,
                    ),
                    TextButton(
                      onPressed:
                          state.areAllCollapsed() ? null : state.collapseAll,
                      child: const Text('Collapse All'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Expanded(
                  child: JsonDataExplorer(
                    nodes: state.displayNodes,
                    itemScrollController: state.itemScrollController,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future loadJsonDataFrom(String url) async {
    print('Calling Json API');
    final data = await http.read(Uri.parse(url));
    print('Done!');
    var decoded = json.decode(data);
    store.buildNodes(decoded, isAllCollapsed: true);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

/// A button that navigates to the data explorer page on pressed.
class _OpenJsonButton extends StatelessWidget {
  final String url;
  final String title;
  final EdgeInsets padding;

  const _OpenJsonButton({
    Key? key,
    required this.url,
    required this.title,
    this.padding = const EdgeInsets.only(bottom: 8.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: ElevatedButton(
          child: Text(title),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => DataExplorerPage(
                jsonUrl: url,
                title: title,
              ),
            ),
          ),
        ),
      );
}
