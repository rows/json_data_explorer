<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

A highly customizable widget to render and interact with JSON objects.

[Provider](doc/interaction.mp4)

<!-- TODO: change branch links /docs -->
<p>
  <img src="https://github.com/rows/json-data-explorer/blob/doc/doc/interaction.gif?raw=true"
   alt="An animated image of the json widget interaction" height="400"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://github.com/rows/json-data-explorer/blob/doc/doc/search.gif?raw=true"
   alt="An animated image of the search capabilities" height="400"/>
</p>

## Features

- Expand and collapse classes and array nodes.
- Dynamic search with highlight.
- Configurable theme and interactions.
- Configurable data display format.
- Indentation guidelines.
- Interaction with URL values.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

The data to be displayed is managed by a store, the `DataExplorerStore`. 
In order to use all features from this package you need to register it in 
a [Provider](https://pub.dev/packages/provider).

```dart
final DataExplorerStore store = DataExplorerStore();

/// ...
ChangeNotifierProvider.value(
  value: store,
  child:
/// ...
```

To load a json object, use  `DataExplorerStore.build` nodes method.

```dart
store.buildNodes(json.decode(myJson));
```

To display the data explorer, you can use the `JsonDataExplorer` widget. 
The only required parameter is a list of node models, which you can take
from the `DataExplorerStore` after a json was decoded.

```dart
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
          builder: (context, state, child) => JsonDataExplorer(
            nodes: state.displayNodes,
          ),
        ),
      ),
    ),
  );
}
```

This will display a decoded json using a default theme.

Check the `/example` app for more information on how to customize the
look and feel of `JsonDataExplorer`.

## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.
