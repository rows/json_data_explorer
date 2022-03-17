import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// A view model state that represents a single node item in a json object tree.
/// A decoded json object can be converted to a [NodeViewModelState] by calling
/// the [buildViewModelNodes] method.
///
/// A node item can be eiter a class root, an array or a single
/// class/array field.
///
///
/// The string [key] is the same as the json key, unless this node is an element
/// if an array, then its key is its index in the array.
///
/// The node [value] behaviour depends on what this node represents, if it is
/// a property (from json: "key": "value"), then the value is the actual
/// property value, one of [num], [String], [bool], [Null]. Since this node
/// represents a single property, both [isClass] and [isArray] are false.
///
/// If this node represents a class, [value] contains a
/// [Map<String, NodeViewModelState>] with this node's children. In this case
/// [isClass] is true.
///
/// If this node represents an array, [value] contains a
/// [List<NodeViewModelState>] with this node's children. In this case
/// [isArray] is true.
///
/// See also:
/// * [buildViewModelNodes]
/// * [flatten]
class NodeViewModelState extends ChangeNotifier {
  /// This attribute name.
  final String key;

  /// This attribute value, it may be one of the following:
  /// [num], [String], [bool], [Null], [Map<String, NodeViewModelState>] or
  /// [List<NodeViewModelState>].
  final dynamic value;

  /// How deep in the tree this node is.
  final int treeDepth;

  /// Flags if this node is a class, if [true], then [value] is as
  /// Map<String, NodeViewModelState>.
  final bool isClass;

  /// Flags if this node is an array, if [true], then [value] is a
  /// [List<NodeViewModelState>].
  final bool isArray;

  /// The children count of this node.
  final int childrenCount;

  bool _isHighlighted = false;
  bool _isCollapsed;

  NodeViewModelState._({
    required this.treeDepth,
    required this.key,
    required this.value,
    this.childrenCount = 0,
    this.isClass = false,
    this.isArray = false,
    bool isCollapsed = false,
  }) : _isCollapsed = isCollapsed;

  /// Build a [NodeViewModelState] as a property.
  /// A property is a single attribute in the json, can be of a type
  /// [num], [String], [bool] or [Null].
  ///
  /// Properties always return [false] when calling [isClass], [isArray]
  /// and [isRoot]
  factory NodeViewModelState.fromProperty({
    required int treeDepth,
    required String key,
    required dynamic value,
  }) =>
      NodeViewModelState._(
        key: key,
        value: value,
        treeDepth: treeDepth,
      );

  /// Build a [NodeViewModelState] as a class.
  /// A class is a JSON node containing a whole class, a class can have
  /// multiple children properties, classes or arrays.
  /// Its value is always a [Map<String, NodeViewModelState>] containing the
  /// children information.
  ///
  /// Classes always return [true] when calling [isClass] and [isRoot].
  factory NodeViewModelState.fromClass({
    required int treeDepth,
    required String key,
    required Map<String, NodeViewModelState> value,
  }) =>
      NodeViewModelState._(
        isClass: true,
        key: key,
        value: value,
        childrenCount: value.keys.length,
        treeDepth: treeDepth,
      );

  /// Build a [NodeViewModelState] as an array.
  /// An array is a JSON node containing an array of objects, each element
  /// inside the array is represented by another [NodeViewModelState]. Thus
  /// it can be values or classes.
  /// Its value is always a [List<NodeViewModelState>] containing the
  /// children information.
  ///
  /// Arrays always return [true] when calling [isArray] and [isRoot].
  factory NodeViewModelState.fromArray({
    required int treeDepth,
    required String key,
    required List<dynamic> value,
  }) =>
      NodeViewModelState._(
        isArray: true,
        key: key,
        value: value,
        childrenCount: value.length,
        treeDepth: treeDepth,
      );

  /// Returns [true] if this node is highlighted.
  ///
  /// This is a mutable property, [notifyListeners] is called to notify all
  ///  registered listeners.
  bool get isHighlighted => _isHighlighted;

  /// Returns [true] if this node is collapsed.
  ///
  /// This is a mutable property, [notifyListeners] is called to notify all
  /// registered listeners.
  bool get isCollapsed => _isCollapsed;

  /// Returns [true] if this is a root node.
  ///
  /// A root node is a node that contains multiple children. A class or an
  /// array.
  bool get isRoot => isClass || isArray;

  /// Returns a list of this node's children.
  Iterable<NodeViewModelState> get children {
    if (isClass) {
      return (value as Map<String, NodeViewModelState>).values;
    } else if (isArray) {
      return value as List<NodeViewModelState>;
    }
    return [];
  }

  /// Sets the highlight property of this node and all of its children.
  ///
  /// [notifyListeners] is called to notify all registered listeners.
  void highlight(bool highlight) {
    _isHighlighted = highlight;
    for (var children in children) {
      children.highlight(highlight);
    }
    notifyListeners();
  }

  /// Sets the [isCollapsed] property to [false].
  ///
  /// [notifyListeners] is called to notify all registered listeners.
  void collapse() {
    _isCollapsed = true;
    notifyListeners();
  }

  /// Sets the [isCollapsed] property to [true].
  ///
  /// [notifyListeners] is called to notify all registered listeners.
  void expand() {
    _isCollapsed = false;
    notifyListeners();
  }
}

Map<String, NodeViewModelState> buildViewModelNodes(dynamic object) {
  if (object is Map<String, dynamic>) {
    return _buildClassNodes(object: object);
  }
  return _buildClassNodes(object: {'data': object});
}

Map<String, NodeViewModelState> _buildClassNodes({
  required Map<String, dynamic> object,
  int treeDepth = 0,
}) {
  final map = <String, NodeViewModelState>{};
  object.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      final subClass = _buildClassNodes(
        object: value,
        treeDepth: treeDepth + 1,
      );
      map[key] = NodeViewModelState.fromClass(
        treeDepth: treeDepth,
        key: key,
        value: subClass,
      );
    } else if (value is List) {
      final array = _buildArrayNodes(
        object: value,
        treeDepth: treeDepth,
      );
      map[key] = NodeViewModelState.fromArray(
        treeDepth: treeDepth,
        key: key,
        value: array,
      );
    } else {
      map[key] = NodeViewModelState.fromProperty(
        key: key,
        value: value,
        treeDepth: treeDepth,
      );
    }
  });
  return map;
}

List<NodeViewModelState> _buildArrayNodes({
  required List<dynamic> object,
  int treeDepth = 0,
}) {
  final array = <NodeViewModelState>[];
  for (int i = 0; i < object.length; i++) {
    final arrayValue = object[i];

    if (arrayValue is Map<String, dynamic>) {
      final classNode = _buildClassNodes(
        object: arrayValue,
        treeDepth: treeDepth + 2,
      );
      array.add(
        NodeViewModelState.fromClass(
          key: i.toString(),
          value: classNode,
          treeDepth: treeDepth + 1,
        ),
      );
    } else {
      array.add(
        NodeViewModelState.fromProperty(
          key: i.toString(),
          value: arrayValue,
          treeDepth: treeDepth + 1,
        ),
      );
    }
  }
  return array;
}

List<NodeViewModelState> flatten(dynamic object) {
  if (object is List) {
    return _flattenArray(object as List<NodeViewModelState>);
  }
  return _flattenClass(object as Map<String, NodeViewModelState>);
}

List<NodeViewModelState> _flattenClass(Map<String, NodeViewModelState> object) {
  final flatList = <NodeViewModelState>[];
  object.forEach((key, value) {
    flatList.add(value);

    if (!value.isCollapsed) {
      if (value.value is Map) {
        flatList.addAll(_flattenClass(value.value));
      } else if (value.value is List) {
        flatList.addAll(_flattenArray(value.value));
      }
    }
  });
  return flatList;
}

List<NodeViewModelState> _flattenArray(List<NodeViewModelState> objects) {
  final flatList = <NodeViewModelState>[];
  for (final object in objects) {
    flatList.add(object);
    if (!object.isCollapsed &&
        object.value is Map<String, NodeViewModelState>) {
      flatList.addAll(_flattenClass(object.value));
    }
  }
  return flatList;
}

/// Handles the data and manages the state of a data explorer.
///
/// The data must be initialized by calling the [buildNodes] method.
/// This method takes a raw JSON object [Map<String, dynamic>] or
/// [List<dynamic>] and builds a flat node list of [NodeViewModelState].
///
///
/// The property [displayNodes] contains a flat list of all nodes that can be
/// displayed.
/// This means that each node property is an element in this list, even inner
/// class properties.
///
/// ## Example
///
/// {@tool snippet}
///
/// Considering the following JSON file with inner classes and properties:
///
/// ```json
/// {
///   "someClass": {
///     "classField": "value",
///     "innerClass": {
///         "innerClassField": "value"
///         }
///     }
///     "arrayField": [0, 1]
/// }
///
/// The [displayNodes] representation is going to look like this:
/// [
///   node {"someClass": ...},
///   node {"classField": ...},
///   node {"innerClass": ...},
///   node {"innerClassField": ...},
///   node {"arrayField": ...},
///   node {"0": ...},
///   node {"1": ...},
/// ]
///
/// ```
/// {@end-tool}
///
/// This data structure allows us to render the nodes easily using a
/// [ListView.builder] for example, or any other kind of list rendering widget.
///
class DataExplorerStore extends ChangeNotifier {
  final itemScrollController = ItemScrollController();

  List<NodeViewModelState> _displayNodes = [];
  UnmodifiableListView<NodeViewModelState> _allNodes = UnmodifiableListView([]);

  // TODO: maybe the search should be in another store.
  final _searchResults = <NodeViewModelState>[];
  String _searchTerm = '';

  /// Gets the list of nodes to be displayed.
  ///
  /// [notifyListeners] is called whenever this value changes.
  /// The returned [Iterable] is closed for modification.
  Iterable<NodeViewModelState> get displayNodes =>
      UnmodifiableListView(_displayNodes);

  /// Gets the current search term.
  ///
  /// [notifyListeners] is called whenever this value changes.
  String get searchTerm => _searchTerm;

  /// Gets a list containing the nodes found by the current search term.
  ///
  /// [notifyListeners] is called whenever this value changes.
  /// The returned [Iterable] is closed for modification.
  Iterable<NodeViewModelState> get searchResults =>
      UnmodifiableListView(_searchResults);

  /// Collapses the given [node] so its children won't be visible.
  ///
  /// This will change the [node] [NodeViewModelState.isCollapsed] property to
  /// true. But its children won't change states, so when the node is expanded
  /// its children states are unchanged.
  ///
  /// [notifyListeners] is called to notify all registered listeners.
  ///
  /// See also:
  /// * [expandNode]
  void collapseNode(NodeViewModelState node) {
    if (node.isCollapsed || !node.isRoot) {
      return;
    }

    final nodeIndex = _displayNodes.indexOf(node) + 1;
    final children = _visibleChildrenCount(node) - 1;
    _displayNodes.removeRange(nodeIndex, nodeIndex + children);
    node.collapse();
    notifyListeners();
  }

  /// Collapses all nodes.
  ///
  /// This collapses every single node of the data structure, meaning that only
  /// the upper root nodes will be in the [displayNodes] list.
  ///
  /// [notifyListeners] is called to notify all registered listeners.
  ///
  /// See also:
  /// * [expandAll]
  void collapseAll() {
    final rootNodes =
        _displayNodes.where((node) => node.treeDepth == 0 && !node.isCollapsed);
    final collapsedNodes = List<NodeViewModelState>.from(_displayNodes);
    for (final node in rootNodes) {
      final nodeIndex = collapsedNodes.indexOf(node) + 1;
      final children = _visibleChildrenCount(node) - 1;
      collapsedNodes.removeRange(nodeIndex, nodeIndex + children);
    }

    for (final node in _allNodes) {
      node.collapse();
    }
    _displayNodes = collapsedNodes;
    notifyListeners();
  }

  /// Expands the given [node] so its children become visible.
  ///
  /// This will change the [node] [NodeViewModelState.isCollapsed] property to
  /// false. But its children won't change states, so when the node is expanded
  /// its children states are unchanged.
  ///
  /// [notifyListeners] is called to notify all registered listeners.
  ///
  /// See also:
  /// * [collapseNode]
  void expandNode(NodeViewModelState node) {
    if (!node.isCollapsed || !node.isRoot) {
      return;
    }

    final nodeIndex = _displayNodes.indexOf(node) + 1;
    final nodes = flatten(node.value);
    _displayNodes.insertAll(nodeIndex, nodes);
    node.expand();
    notifyListeners();
  }

  /// Expands all nodes.
  ///
  /// This expands every single node of the data structure, meaning that all
  /// nodes will be in the [displayNodes] list.
  ///
  /// [notifyListeners] is called to notify all registered listeners.
  ///
  /// See also:
  /// * [collapseAll]
  void expandAll() {
    for (final node in _allNodes) {
      node.expand();
    }
    _displayNodes = List.from(_allNodes);
    notifyListeners();
  }

  /// Executes a search in the current data structure looking for the given
  /// search [term].
  ///
  /// The search looks for matching terms in both key and values from all nodes.
  /// The results can be retrieved in the [searchResults] lists.
  ///
  /// [notifyListeners] is called to notify all registered listeners.
  void search(String term) {
    _searchTerm = term.toLowerCase();
    _searchResults.clear();
    notifyListeners();

    if (term.isNotEmpty) {
      _doSearch();
    }
  }

  /// Uses the given [jsonObject] to build the [displayNodes] list.
  ///
  /// If [isAllCollapsed] is true, then all nodes will be collapsed, and
  /// initially only upper root nodes will be in the list.
  ///
  /// [notifyListeners] is called to notify all registered listeners.
  Future buildNodes(dynamic jsonObject, {bool isAllCollapsed = false}) async {
    // TODO: remove stopwatch and print.
    Stopwatch stopwatch = Stopwatch()..start();
    final builtNodes = buildViewModelNodes(jsonObject);
    final flatList = flatten(builtNodes);

    _allNodes = UnmodifiableListView(flatList);
    _displayNodes = List.from(flatList);
    if (isAllCollapsed) {
      collapseAll();
    }
    notifyListeners();
    print('Built ${flatList.length} nodes.');
    print('executed in ${stopwatch.elapsed}.');
  }

  int _visibleChildrenCount(NodeViewModelState node) {
    final children = node.children;
    int count = 1;
    for (final child in children) {
      count =
          child.isCollapsed ? count + 1 : count + _visibleChildrenCount(child);
    }
    return count;
  }

  // TODO: not optimal way to do this. Maybe change to a stream once we leave
  // the SPIKE phase.
  // Also we are scrolling only to the first item for demo purposes.
  Future _doSearch() {
    return Future(() {
      for (final node in _allNodes) {
        if (node.key.toLowerCase().contains(searchTerm)) {
          _searchResults.add(node);
        }
        if (!node.isRoot) {
          if (node.value.toString().toLowerCase().contains(searchTerm)) {
            _searchResults.add(node);
          }
        }
      }

      if (_searchResults.isNotEmpty) {
        notifyListeners();
        final index = _displayNodes.indexOf(_searchResults.first);
        if (index != -1) {
          itemScrollController.scrollTo(
            index: _displayNodes.indexOf(_searchResults.first),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }
}
