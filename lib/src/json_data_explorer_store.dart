import 'package:flutter/widgets.dart';

import 'models/node.dart';

class JsonDataExplorerStore extends ChangeNotifier {
  Node? node;

  Future<void> initializeNode(dynamic json) async {
    if (json is Map<String, dynamic>) {
      final classNode = ClassNode();

      classNode.setChildren(_buildNodes(classNode, json));

      node = classNode;
    } else if (json is List) {
      final arrayNode = ArrayNode();

      arrayNode.setChildren(_buildNodes(arrayNode, json));

      node = arrayNode;
    } else {
      node = LeafNode();
    }

    notifyListeners();
  }

  List<Node> _buildNodes(Node parentNode, dynamic object) {
    final children = <Node>[];

    object.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final classNode = ClassNode();

        classNode.setParentNode(parentNode);

        classNode.setChildren(_buildNodes(classNode, value));

        children.add(classNode);
      } else if (value is List) {
        final arrayNode = ArrayNode();

        arrayNode.setParentNode(parentNode);

        arrayNode.setChildren(_buildNodes(arrayNode, value));

        children.add(arrayNode);
      } else {
        final leafNode = LeafNode();

        leafNode.setParentNode(parentNode);

        children.add(leafNode);
      }
    });

    return children;
  }
}
