import 'dart:convert';

import 'package:data_explorer/data_explorer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCallbackFunction extends Mock {
  call();
}

const testJson = '''
{
  "firstClass": {
    "firstClass.firstField": "firstField",
    "firstClass.secondField": "secondField",
    "firstClass.thirdField": "thirdField",
    "firstClass.firstClassField": {
      "firstClassField.firstField": "firstField",
      "firstClassField.secondField": "secondField",
      "firstClassField.thirdField": "thirdField",
      "firstClassField.innerClassField": {
        "innerClassField.firstField": "firstField",
        "innerClassField.secondField": "secondField",
        "innerClassField.thirdField": "thirdField"
      }
    },
    "firstClass.secondClassField": {
      "secondClassField.firstField": "firstField",
      "secondClassField.secondField": "secondField",
      "secondClassField.thirdField": "thirdField",
      "secondClassField.innerClassField": {
        "innerClassField.firstField": "firstField",
        "innerClassField.secondField": "secondField",
        "innerClassField.thirdField": "thirdField"
      }
    },
    "firstClass.array": [
      0,
      1,
      2
    ]
  },
  "secondClass": {
    "secondClass.firstField": "firstField",
    "secondClass.secondField": "secondField",
    "secondClass.thirdField": "thirdField",
    "secondClass.firstClassField": {
      "firstClassField.firstField": "firstField",
      "firstClassField.secondField": "secondField",
      "firstClassField.thirdField": "thirdField",
      "firstClassField.innerClassField": {
        "innerClassField.firstField": "firstField",
        "innerClassField.secondField": "secondField",
        "innerClassField.thirdField": "thirdField"
      }
    },
    "secondClass.secondClassField": {
      "secondClassField.firstField": "firstField",
      "secondClassField.secondField": "secondField",
      "secondClassField.thirdField": "thirdField",
      "secondClassField.innerClassField": {
        "innerClassField.firstField": "firstField",
        "innerClassField.secondField": "secondField",
        "innerClassField.thirdField": "thirdField"
      }
    },
    "secondClass.array": [
      0,
      1,
      2
    ]
  }
}
''';

void main() {
  group('DataExplorerStore', () {
    test('build nodes', () {
      final store = DataExplorerStore();
      store.buildNodes(json.decode(testJson));
      expect(store.displayNodes, hasLength(48));
      expect(store.displayNodes.elementAt(0).key, 'firstClass');
      expect(store.displayNodes.elementAt(24).key, 'secondClass');
    });

    test('build all collapsed nodes', () {
      final store = DataExplorerStore();
      store.buildNodes(json.decode(testJson), isAllCollapsed: true);
      expect(store.displayNodes, hasLength(2));
      expect(store.displayNodes.elementAt(0).key, 'firstClass');
      expect(store.displayNodes.elementAt(1).key, 'secondClass');
      expect(store.areAllExpanded, isFalse);
      expect(store.areAllCollapsed(), isTrue);
    });

    test('build nodes notifies listeners', () {
      final store = DataExplorerStore();
      final listener = MockCallbackFunction();
      store.addListener(listener);

      store.buildNodes(json.decode(testJson));
      verify(() => listener.call()).called(1);
    });

    test('build collapsed nodes notifies listeners', () {
      final store = DataExplorerStore();
      final listener = MockCallbackFunction();
      store.addListener(listener);

      store.buildNodes(json.decode(testJson), isAllCollapsed: true);
      verify(() => listener.call()).called(1);
    });

    test('collapse all nodes', () {
      final store = DataExplorerStore();
      store.buildNodes(json.decode(testJson));

      final listener = MockCallbackFunction();
      store.addListener(listener);
      store.collapseAll();

      expect(store.displayNodes, hasLength(2));
      expect(store.displayNodes.elementAt(0).key, 'firstClass');
      expect(store.displayNodes.elementAt(1).key, 'secondClass');
      verify(() => listener.call()).called(1);

      expect(store.areAllExpanded, isFalse);
      expect(store.areAllCollapsed(), isTrue);
    });

    test('expand all nodes', () {
      final store = DataExplorerStore();
      store.buildNodes(json.decode(testJson), isAllCollapsed: true);

      final listener = MockCallbackFunction();
      store.addListener(listener);
      store.expandAll();

      expect(store.displayNodes, hasLength(48));
      expect(store.displayNodes.elementAt(0).key, 'firstClass');
      expect(store.displayNodes.elementAt(24).key, 'secondClass');
      verify(() => listener.call()).called(1);

      expect(store.areAllExpanded, isTrue);
      expect(store.areAllCollapsed(), isFalse);
    });

    test('collapse node', () {
      final store = DataExplorerStore();
      store.buildNodes(json.decode(testJson));

      final listener = MockCallbackFunction();
      store.addListener(listener);

      expect(store.displayNodes, hasLength(48));
      store.collapseNode(store.displayNodes.first);

      expect(store.displayNodes, hasLength(25));
      expect(store.displayNodes.elementAt(0).key, 'firstClass');
      expect(store.displayNodes.elementAt(1).key, 'secondClass');
      verify(() => listener.call()).called(1);

      expect(store.areAllExpanded, isFalse);
      expect(store.areAllCollapsed(), isFalse);
    });

    test("collapse won't do anything for non root nodes", () {
      final store = DataExplorerStore();
      store.buildNodes(json.decode(testJson));
      expect(store.displayNodes, hasLength(48));

      final listener = MockCallbackFunction();
      store.addListener(listener);

      store.collapseNode(store.displayNodes.elementAt(1));

      expect(store.displayNodes, hasLength(48));
      expect(store.displayNodes.elementAt(1).isCollapsed, isFalse);
      verifyNever(() => listener.call());
    });

    test("collapse won't do anything for already collapsed nodes", () {
      final store = DataExplorerStore();
      store.buildNodes(json.decode(testJson), isAllCollapsed: true);
      expect(store.displayNodes, hasLength(2));

      final listener = MockCallbackFunction();
      store.addListener(listener);

      store.collapseNode(store.displayNodes.first);

      expect(store.displayNodes, hasLength(2));
      expect(store.displayNodes.first.isCollapsed, isTrue);
      verifyNever(() => listener.call());
    });

    test('expand node', () {
      final store = DataExplorerStore();
      store.buildNodes(json.decode(testJson), isAllCollapsed: true);

      final listener = MockCallbackFunction();
      store.addListener(listener);

      expect(store.displayNodes, hasLength(2));
      store.expandNode(store.displayNodes.first);

      expect(store.displayNodes, hasLength(8));
      expect(store.displayNodes.elementAt(0).key, 'firstClass');
      expect(store.displayNodes.elementAt(7).key, 'secondClass');
      verify(() => listener.call()).called(1);

      expect(store.areAllExpanded, isFalse);
      expect(store.areAllCollapsed(), isFalse);
    });

    test("expand won't do anything for non root nodes", () {
      final store = DataExplorerStore();
      store.buildNodes(json.decode(testJson), isAllCollapsed: true);
      store.expandNode(store.displayNodes.first);
      expect(store.displayNodes, hasLength(8));

      /// Force view model value as collapsed.
      store.displayNodes.elementAt(1).collapse();

      final listener = MockCallbackFunction();
      store.addListener(listener);

      store.expandNode(store.displayNodes.elementAt(1));

      expect(store.displayNodes, hasLength(8));
      expect(store.displayNodes.elementAt(1).isCollapsed, isTrue);
      verifyNever(() => listener.call());
    });

    test("expand won't do anything for already expanded nodes", () {
      final store = DataExplorerStore();
      store.buildNodes(json.decode(testJson));
      expect(store.displayNodes, hasLength(48));

      final listener = MockCallbackFunction();
      store.addListener(listener);

      store.expandNode(store.displayNodes.first);

      expect(store.displayNodes, hasLength(48));
      expect(store.displayNodes.first.isCollapsed, isFalse);
      verifyNever(() => listener.call());
    });

    test("expand and collapse won't change collapse state of children nodes",
        () {
      final store = DataExplorerStore();
      store.buildNodes(json.decode(testJson));
      expect(store.displayNodes, hasLength(48));

      final listener = MockCallbackFunction();
      store.addListener(listener);

      // Just make sure the this element is our expected inner class.
      expect(store.displayNodes.elementAt(4).key, 'firstClass.firstClassField');

      store.collapseNode(store.displayNodes.elementAt(4));
      expect(store.displayNodes, hasLength(41));

      // Now collapse the parent class node.
      store.collapseNode(store.displayNodes.elementAt(0));
      expect(store.displayNodes, hasLength(25));
      expect(store.displayNodes.elementAt(0).key, 'firstClass');
      expect(store.displayNodes.elementAt(1).key, 'secondClass');

      // Expand again and check if firstClass.firstClassField node still
      // collapsed and firstClass.secondClassField still expanded.
      store.expandNode(store.displayNodes.elementAt(0));
      expect(store.displayNodes, hasLength(41));
      expect(store.displayNodes.elementAt(4).key, 'firstClass.firstClassField');
      expect(store.displayNodes.elementAt(4).isCollapsed, isTrue);
      expect(
        store.displayNodes.elementAt(5).key,
        'firstClass.secondClassField',
      );
      expect(store.displayNodes.elementAt(5).isCollapsed, isFalse);

      verify(() => listener.call()).called(3);
    });
  });
}
