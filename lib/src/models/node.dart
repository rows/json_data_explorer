abstract class Node {
  Node? parent;

  Node();

  void setParentNode(Node parent) {
    this.parent = parent;
  }
}

class RootNode extends Node {
  List<Node>? children;

  RootNode();

  void setChildren(List<Node> children) {
    this.children = children;
  }
}

class ClassNode extends RootNode {}

class ArrayNode extends RootNode {}

class LeafNode extends Node {}
