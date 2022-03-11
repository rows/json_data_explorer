import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class JsonDataExplorer extends StatelessWidget {
  final List<FlatJsonNodeModelState> nodes;
  final ItemScrollController? itemScrollController;
  final ItemPositionsListener? itemPositionsListener;

  const JsonDataExplorer({
    Key? key,
    required this.nodes,
    this.itemScrollController,
    this.itemPositionsListener,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ScrollablePositionedList.builder(
        itemCount: nodes.length,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        itemBuilder: (context, index) => _JsonAttribute(
          node: nodes[index],
        ),
      );
}

class _JsonAttribute extends StatelessWidget {
  final FlatJsonNodeModelState node;
  final double indentationPadding;

  const _JsonAttribute({
    Key? key,
    required this.node,
    this.indentationPadding = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: node.treeDepth * indentationPadding),
      child: Text.rich(
        TextSpan(
          text: node.key,
          style: Theme.of(context).textTheme.subtitle1!.copyWith(
                fontWeight: FontWeight.bold,
              ),
          children: [
            const TextSpan(
              text: ' ',
            ),
            TextSpan(
              text: _valueDisplay(),
              style: Theme.of(context).textTheme.subtitle1!.copyWith(
                    color: _valueColor(),
                  ),
            ),
          ],
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  String _valueDisplay() {
    if (node.value is Map) {
      return '{${(node.value as Map).length}}';
    } else if (node.value is List) {
      return '[${(node.value as List).length}]';
    }
    return node.value.toString();
  }

  Color _valueColor() {
    if (node.value is Map) {
      return Colors.grey;
    } else if (node.value is List) {
      return Colors.grey;
    }
    return Colors.redAccent;
  }
}

class FlatJsonNodeModelState {
  final String key;
  final dynamic value;
  final int treeDepth;

  FlatJsonNodeModelState({
    required this.treeDepth,
    required this.key,
    required this.value,
  });

  bool get isArray => value is List;

  bool get isClass => value is Map;
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
    widgets.add(
      FlatJsonNodeModelState(
        key: key,
        value: value,
        treeDepth: treeDepth,
      ),
    );

    if (value is Map) {
      widgets.addAll(
        _buildMapNodes(
          object: value as Map<String, dynamic>,
          treeDepth: treeDepth + 1,
        ),
      );
    } else if (value is List) {
      widgets.addAll(_buildArrayNodes(
        object: value,
        treeDepth: treeDepth,
      ));
    }
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
    widgets.add(
      FlatJsonNodeModelState(
        key: i.toString(),
        value: arrayValue,
        treeDepth: treeDepth + 1,
      ),
    );
    if (arrayValue is Map<String, dynamic>) {
      widgets.addAll(
        _buildMapNodes(
          object: arrayValue,
          treeDepth: treeDepth + 2,
        ),
      );
    }
  }
  return widgets;
}

bool _hasBranches(dynamic object) => object is Map || object is List;
