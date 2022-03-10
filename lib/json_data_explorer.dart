import 'package:flutter/material.dart';

class JsonDataExplorer extends StatelessWidget {
  final List<FlatJsonNodeModelState> nodes;

  const JsonDataExplorer({Key? key, required this.nodes}) : super(key: key);

  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: nodes.length,
        itemBuilder: (context, index) => _JsonAttribute(
          name: nodes[index].key,
          value: nodes[index].value,
          treeDepth: nodes[index].treeDepth,
        ),
      );
}

/// Testing a list view, bad performance
class JsonDataViewerListView extends StatelessWidget {
  final dynamic content;

  const JsonDataViewerListView({Key? key, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (content == null) {
      return const Text('{}');
    } else {
      return ListView(
        children: _buildNodes(object: content),
      );
    }
  }

  List<Widget> _buildNodes({
    required Map<String, dynamic> object,
    int treeDepth = 0,
  }) {
    final widgets = <Widget>[];
    object.forEach((key, value) {
      widgets.add(
        _JsonAttribute(
          name: key,
          value: value,
          treeDepth: treeDepth,
        ),
      );

      if (value is Map) {
        widgets.addAll(
          _buildNodes(
            object: value as Map<String, dynamic>,
            treeDepth: treeDepth + 1,
          ),
        );
      } else if (value is List) {
        for (int i = 0; i < value.length; i++) {
          widgets.addAll(
            _buildNodes(
              object: value[i],
              treeDepth: treeDepth + 1,
            ),
          );
        }
      }
    });
    return widgets;
  }
}

class _JsonAttribute extends StatelessWidget {
  final String name;
  final dynamic value;
  final int treeDepth;
  final double indentationPadding;

  const _JsonAttribute({
    Key? key,
    required this.name,
    required this.value,
    required this.treeDepth,
    this.indentationPadding = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: treeDepth * indentationPadding),
      child: Text.rich(
        TextSpan(
          text: name,
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
    if (value is Map) {
      return '{${(value as Map).length}}';
    } else if (value is List) {
      return '[${(value as List).length}]';
    }
    return value.toString();
  }

  Color _valueColor() {
    if (value is Map) {
      return Colors.grey;
    } else if (value is List) {
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
