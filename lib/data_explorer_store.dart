import 'package:flutter/widgets.dart';

class FlatJsonNodeModelState extends ChangeNotifier {
  final String key;
  final dynamic value;
  final int treeDepth;
  final bool isClass;
  final bool isArray;

  bool isHighlighted = false;
  bool isCollapsed = false;

  FlatJsonNodeModelState({
    required this.treeDepth,
    required this.key,
    required this.value,
    this.isClass = false,
    this.isArray = false,
  });

  bool get isRoot => value is List<FlatJsonNodeModelState>;

  void highlight(bool highlight) {
    isHighlighted = highlight;
    if (value is List<FlatJsonNodeModelState>) {
      for (final children in value) {
        children.highlight(highlight);
      }
    }
    notifyListeners();
  }

  void collapse() {
    isCollapsed = true;
    notifyListeners();
  }

  void expand() {
    isCollapsed = false;
    notifyListeners();
  }

  int childrenCount() {
    if (value is List<FlatJsonNodeModelState>) {
      return value.length;
    }
    return 0;
  }
}

/// Test cases:
///   - Map
///   - Array of objects
///   - Array of types
List<FlatJsonNodeModelState> buildJsonNodes(
  dynamic object,
) {
  if (object is Map<String, dynamic>) {
    return _buildMapNodes(object: object);
  }
  return _buildArrayNodes(
    object: object as List,
    treeDepth: -1,
  );
}

List<FlatJsonNodeModelState> _buildMapNodes({
  required Map<String, dynamic> object,
  int treeDepth = 0,
}) {
  final widgets = <FlatJsonNodeModelState>[];
  object.forEach((key, value) {
    final nodeChildren = <FlatJsonNodeModelState>[];
    bool isClass = false;
    bool isArray = false;
    if (value is Map) {
      nodeChildren.addAll(
        _buildMapNodes(
          object: value as Map<String, dynamic>,
          treeDepth: treeDepth + 1,
        ),
      );
      isClass = true;
    } else if (value is List) {
      nodeChildren.addAll(_buildArrayNodes(
        object: value,
        treeDepth: treeDepth,
      ));
      isArray = true;
    }
    widgets.add(
      FlatJsonNodeModelState(
        key: key,
        value: nodeChildren.isNotEmpty ? nodeChildren : value,
        treeDepth: treeDepth,
        isClass: isClass,
        isArray: isArray,
      ),
    );
    widgets.addAll(nodeChildren);
  });
  return widgets;
}

List<FlatJsonNodeModelState> _buildArrayNodes({
  required List<dynamic> object,
  int treeDepth = 0,
}) {
  final widgets = <FlatJsonNodeModelState>[];
  for (int i = 0; i < object.length; i++) {
    final arrayValue = object[i];
    final nodeChildren = <FlatJsonNodeModelState>[];
    bool isClass = false;
    if (arrayValue is Map<String, dynamic>) {
      nodeChildren.addAll(
        _buildMapNodes(
          object: arrayValue,
          treeDepth: treeDepth + 2,
        ),
      );
      isClass = true;
    }
    widgets.add(
      FlatJsonNodeModelState(
        key: i.toString(),
        value: isClass ? nodeChildren : arrayValue,
        treeDepth: treeDepth + 1,
        isClass: isClass,
      ),
    );
    widgets.addAll(nodeChildren);
  }
  return widgets;
}

class DataExplorerStore extends ValueNotifier<List<FlatJsonNodeModelState>> {
  List<FlatJsonNodeModelState> _allNodes;

  DataExplorerStore()
      : _allNodes = [],
        super([]);

  void collapseNode(FlatJsonNodeModelState node) {
    if (node.isCollapsed || !node.isRoot) {
      return;
    }

    final nodeIndex = value.indexOf(node) + 1;
    final children = node.childrenCount();
    value.removeRange(nodeIndex, nodeIndex + children);
    node.collapse();
    notifyListeners();
  }

  void expandNode(FlatJsonNodeModelState node) {
    if (!node.isCollapsed || !node.isRoot) {
      return;
    }

    final nodeIndex = _allNodes.indexOf(node) + 1;
    final children = node.childrenCount();
    final nodes = _allNodes.skip(nodeIndex).take(children);

    value.insertAll(value.indexOf(node) + 1, nodes);
    node.expand();
    notifyListeners();
  }

  Future buildNodes(dynamic jsonObject) async {
    final builtNodes = buildJsonNodes(jsonObject);
    print('Built ${builtNodes.length} nodes.');

    _allNodes = builtNodes;
    value = List.from(_allNodes);
  }
}
