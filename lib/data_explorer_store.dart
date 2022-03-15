import 'package:flutter/widgets.dart';

class FlatJsonNodeModelState extends ChangeNotifier {
  final String key;
  final dynamic value;
  final int treeDepth;
  final bool isClass;
  final bool isArray;
  final int childrenCount;

  bool isHighlighted = false;
  bool isCollapsed = false;

  FlatJsonNodeModelState({
    required this.treeDepth,
    required this.key,
    required this.value,
    this.childrenCount = 0,
    this.isClass = false,
    this.isArray = false,
  });

  factory FlatJsonNodeModelState.fromClass({
    required int treeDepth,
    required String key,
    required Map<String, dynamic> value,
  }) =>
      FlatJsonNodeModelState(
        isClass: true,
        key: key,
        value: value,
        childrenCount: value.keys.length,
        treeDepth: treeDepth,
      );

  factory FlatJsonNodeModelState.fromArray({
    required int treeDepth,
    required String key,
    required List<dynamic> value,
  }) =>
      FlatJsonNodeModelState(
        isArray: true,
        key: key,
        value: value,
        childrenCount: value.length,
        treeDepth: treeDepth,
      );

  bool get isRoot => isClass || isArray;

  Iterable<FlatJsonNodeModelState> get children {
    if (isClass) {
      return (value as Map<String, FlatJsonNodeModelState>).values;
    } else if (isArray) {
      return value as List<FlatJsonNodeModelState>;
    }
    return [];
  }

  void highlight(bool highlight) {
    isHighlighted = highlight;
    for (var children in children) {
      children.highlight(highlight);
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
}

Map<String, FlatJsonNodeModelState> buildViewModelNodes(
  dynamic object,
) {
  if (object is Map<String, dynamic>) {
    return _buildClassNodes(object: object);
  }
  return _buildClassNodes(object: {'data': object});
}

Map<String, FlatJsonNodeModelState> _buildClassNodes({
  required Map<String, dynamic> object,
  int treeDepth = 0,
}) {
  final map = <String, FlatJsonNodeModelState>{};
  object.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      final subClass = _buildClassNodes(
        object: value,
        treeDepth: treeDepth + 1,
      );
      map[key] = FlatJsonNodeModelState.fromClass(
        treeDepth: treeDepth,
        key: key,
        value: subClass,
      );
    } else if (value is List) {
      final array = _buildArrayNodes(
        object: value,
        treeDepth: treeDepth,
      );
      map[key] = FlatJsonNodeModelState.fromArray(
        treeDepth: treeDepth,
        key: key,
        value: array,
      );
    } else {
      map[key] = FlatJsonNodeModelState(
        key: key,
        value: value,
        treeDepth: treeDepth,
      );
    }
  });
  return map;
}

List<FlatJsonNodeModelState> _buildArrayNodes({
  required List<dynamic> object,
  int treeDepth = 0,
}) {
  final array = <FlatJsonNodeModelState>[];
  for (int i = 0; i < object.length; i++) {
    final arrayValue = object[i];

    Map<String, dynamic>? jsonClass;
    if (arrayValue is Map<String, dynamic>) {
      jsonClass = _buildClassNodes(
        object: arrayValue,
        treeDepth: treeDepth + 2,
      );
    }
    array.add(
      FlatJsonNodeModelState(
        key: i.toString(),
        value: jsonClass ?? arrayValue,
        treeDepth: treeDepth + 1,
        childrenCount: jsonClass != null ? jsonClass.keys.length : 0,
        isClass: jsonClass != null,
      ),
    );
  }
  return array;
}

List<FlatJsonNodeModelState> flatten(dynamic object) {
  if (object is List) {
    return _flattenArray(object as List<FlatJsonNodeModelState>);
  }
  return _flattenClass(object as Map<String, FlatJsonNodeModelState>);
}

List<FlatJsonNodeModelState> _flattenClass(
    Map<String, FlatJsonNodeModelState> object) {
  final flatList = <FlatJsonNodeModelState>[];
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

List<FlatJsonNodeModelState> _flattenArray(
    List<FlatJsonNodeModelState> objects) {
  final flatList = <FlatJsonNodeModelState>[];
  for (final object in objects) {
    flatList.add(object);
    if (!object.isCollapsed &&
        object.value is Map<String, FlatJsonNodeModelState>) {
      flatList.addAll(_flattenClass(object.value));
    }
  }
  return flatList;
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
    final children = _visibleChildrenCount(node) - 1;
    print('Children $children');

    value.removeRange(nodeIndex, nodeIndex + children);
    node.collapse();
    notifyListeners();
  }

  void expandNode(FlatJsonNodeModelState node) {
    if (!node.isCollapsed || !node.isRoot) {
      return;
    }

    final nodeIndex = value.indexOf(node) + 1;
    final nodes = flatten(node.value);
    print('Nodes ${nodes.length}');

    value.insertAll(nodeIndex, nodes);
    node.expand();
    notifyListeners();
  }

  Future buildNodes(dynamic jsonObject) async {
    Stopwatch stopwatch = Stopwatch()..start();
    final builtNodes = buildViewModelNodes(jsonObject);
    final flatList = flatten(builtNodes);
    print('Built ${flatList.length} nodes.');
    print('executed in ${stopwatch.elapsed}.');

    _allNodes = flatList;
    value = List.from(_allNodes);
  }

  int _visibleChildrenCount(FlatJsonNodeModelState node) {
    final children = node.children;
    int count = 1;
    for (final child in children) {
      count =
          child.isCollapsed ? count + 1 : count + _visibleChildrenCount(child);
    }
    return count;
  }
}
