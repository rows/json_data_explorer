// ignore_for_file: avoid_dynamic_calls

import 'package:flutter_test/flutter_test.dart';
import 'package:json_data_explorer/json_data_explorer.dart';
import 'package:mocktail/mocktail.dart';

class MockCallbackFunction extends Mock {
  void call();
}

void main() {
  group('NodeViewModelState', () {
    group('Property', () {
      test('build as a property', () {
        final viewModel = NodeViewModelState.fromProperty(
          treeDepth: 1,
          key: 'key',
          value: 123,
          parent: null,
        );

        expect(viewModel.key, 'key');
        expect(viewModel.value, isA<int>());
        expect(viewModel.value, 123);
        expect(viewModel.isRoot, isFalse);
        expect(viewModel.isClass, isFalse);
        expect(viewModel.isArray, isFalse);
        expect(viewModel.isHighlighted, isFalse);
        expect(viewModel.isCollapsed, isFalse);
        expect(viewModel.parent, isNull);
      });

      test('a property has no children nodes', () {
        final parent = NodeViewModelState.fromArray(
          treeDepth: 1,
          key: 'parentKey',
        );

        final viewModel = NodeViewModelState.fromProperty(
          treeDepth: 1,
          key: 'key',
          value: 123,
          parent: parent,
        );

        expect(viewModel.childrenCount, 0);
        expect(viewModel.children, hasLength(0));
        expect(viewModel.parent!.key, 'parentKey');
      });

      test('highlight notifies listeners', () {
        final viewModel = NodeViewModelState.fromProperty(
          treeDepth: 1,
          key: 'key',
          value: 123,
          parent: null,
        );
        final listener = MockCallbackFunction();
        viewModel.addListener(listener);

        viewModel.highlight();
        expect(viewModel.isHighlighted, isTrue);

        viewModel.highlight(isHighlighted: false);
        expect(viewModel.isHighlighted, isFalse);
        verify(listener.call).called(2);
      });

      test('collapse notifies listeners', () {
        final viewModel = NodeViewModelState.fromProperty(
          treeDepth: 1,
          key: 'key',
          value: 123,
          parent: null,
        );
        final listener = MockCallbackFunction();
        viewModel.addListener(listener);

        viewModel.collapse();
        expect(viewModel.isCollapsed, isTrue);

        viewModel.expand();
        expect(viewModel.isCollapsed, isFalse);
        verify(listener.call).called(2);
      });
    });

    group('Class', () {
      test('build as a class', () {
        final viewModel = NodeViewModelState.fromClass(
          treeDepth: 0,
          key: 'classKey',
        );

        final classMap = {
          'propertyA': NodeViewModelState.fromProperty(
            treeDepth: 1,
            key: 'propertyA',
            value: 123,
            parent: viewModel,
          ),
          'propertyB': NodeViewModelState.fromProperty(
            treeDepth: 1,
            key: 'propertyB',
            value: 'string',
            parent: viewModel,
          ),
        };

        viewModel.setNodeHierarchy(parent: null, children: classMap);

        expect(viewModel.key, 'classKey');
        expect(viewModel.value, isA<Map<String, NodeViewModelState>>());
        expect(viewModel.value, hasLength(2));
        expect(viewModel.isRoot, isTrue);
        expect(viewModel.isClass, isTrue);
        expect(viewModel.isArray, isFalse);
        expect(viewModel.isHighlighted, isFalse);
        expect(viewModel.isCollapsed, isFalse);

        expect(classMap['propertyA']!.parent!.key, 'classKey');
      });

      test('children nodes', () {
        final viewModel = NodeViewModelState.fromClass(
          treeDepth: 0,
          key: 'classKey',
        );

        final classMap = {
          'propertyA': NodeViewModelState.fromProperty(
            treeDepth: 1,
            key: 'propertyA',
            value: 123,
            parent: viewModel,
          ),
          'propertyB': NodeViewModelState.fromProperty(
            treeDepth: 1,
            key: 'propertyB',
            value: 'string',
            parent: viewModel,
          ),
        };

        viewModel.setNodeHierarchy(parent: null, children: classMap);

        expect(viewModel.childrenCount, 2);
        expect(viewModel.children, hasLength(2));
        expect(viewModel.children.elementAt(0).key, 'propertyA');
        expect(viewModel.children.elementAt(1).key, 'propertyB');
      });

      test('highlight sets highlight in all children', () {
        final viewModel = NodeViewModelState.fromClass(
          treeDepth: 0,
          key: 'classKey',
        );

        final subClass = NodeViewModelState.fromClass(
          treeDepth: 1,
          key: 'innerClass',
        );

        final classMap = {
          'property': NodeViewModelState.fromProperty(
            treeDepth: 1,
            key: 'property',
            value: 123,
            parent: viewModel,
          ),
          'innerClass': subClass,
        };

        subClass.setNodeHierarchy(
          parent: viewModel,
          children: {
            'innerClassProperty': NodeViewModelState.fromProperty(
              treeDepth: 2,
              key: 'innerClassProperty',
              value: 123,
              parent: classMap['innerClass'],
            ),
          },
        );

        viewModel.setNodeHierarchy(parent: null, children: classMap);
        viewModel.highlight();

        expect(viewModel.isHighlighted, isTrue);
        expect(classMap['property']!.isHighlighted, isTrue);
        expect(classMap['innerClass']!.isHighlighted, isTrue);
        expect(
          classMap['innerClass']!.value['innerClassProperty']!.isHighlighted,
          isTrue,
        );

        viewModel.highlight(isHighlighted: false);
        expect(viewModel.isHighlighted, isFalse);
        expect(classMap['property']!.isHighlighted, isFalse);
        expect(classMap['innerClass']!.isHighlighted, isFalse);
        expect(
          classMap['innerClass']!.value['innerClassProperty']!.isHighlighted,
          isFalse,
        );
      });
    });

    group('Array', () {
      test('build as an array', () {
        final viewModel = NodeViewModelState.fromArray(
          treeDepth: 0,
          key: 'arrayKey',
        );

        final arrayValues = [
          NodeViewModelState.fromProperty(
            treeDepth: 1,
            key: '0',
            value: 123,
            parent: viewModel,
          ),
          NodeViewModelState.fromProperty(
            treeDepth: 1,
            key: '1',
            value: 'string',
            parent: viewModel,
          ),
        ];

        viewModel.setNodeHierarchy(parent: null, children: arrayValues);

        expect(viewModel.key, 'arrayKey');
        expect(viewModel.value, isA<List<NodeViewModelState>>());
        expect(viewModel.value, hasLength(2));
        expect(viewModel.isRoot, isTrue);
        expect(viewModel.isClass, isFalse);
        expect(viewModel.isArray, isTrue);
        expect(viewModel.isHighlighted, isFalse);
        expect(viewModel.isCollapsed, isFalse);
      });

      test('children nodes', () {
        final viewModel = NodeViewModelState.fromArray(
          treeDepth: 0,
          key: 'arrayKey',
        );

        final arrayValues = [
          NodeViewModelState.fromProperty(
            treeDepth: 1,
            key: '0',
            value: 123,
            parent: viewModel,
          ),
          NodeViewModelState.fromProperty(
            treeDepth: 1,
            key: '1',
            value: 'string',
            parent: viewModel,
          ),
        ];

        viewModel.setNodeHierarchy(parent: null, children: arrayValues);

        expect(viewModel.childrenCount, 2);
        expect(viewModel.children, hasLength(2));
        expect(viewModel.children.elementAt(0).key, '0');
        expect(viewModel.children.elementAt(1).key, '1');
      });

      test('highlight sets highlight in all children', () {
        final viewModel = NodeViewModelState.fromArray(
          treeDepth: 0,
          key: 'arrayKey',
        );

        final subClass = NodeViewModelState.fromClass(
          treeDepth: 1,
          key: 'class',
        );

        subClass.setNodeHierarchy(
          parent: viewModel,
          children: {
            'classProperty': NodeViewModelState.fromProperty(
              treeDepth: 2,
              key: 'classProperty',
              value: 123,
              parent: subClass,
            ),
          },
        );

        final arrayValues = [subClass];

        viewModel.setNodeHierarchy(parent: null, children: arrayValues);
        viewModel.highlight();

        expect(viewModel.isHighlighted, isTrue);
        expect(arrayValues[0].isHighlighted, isTrue);
        expect(arrayValues[0].value['classProperty']!.isHighlighted, isTrue);

        viewModel.highlight(isHighlighted: false);
        expect(viewModel.isHighlighted, isFalse);
        expect(arrayValues[0].isHighlighted, isFalse);
        expect(arrayValues[0].value['classProperty']!.isHighlighted, isFalse);
      });
    });

    group('parent nodes', () {
      test('work properly', () {
        final firstClass = NodeViewModelState.fromClass(
          treeDepth: 0,
          key: 'firstClass',
        );

        final firstClassFirstField = NodeViewModelState.fromClass(
          treeDepth: 1,
          key: 'firstClass.firstField',
        );

        final firstClassFirstClassField = NodeViewModelState.fromClass(
          treeDepth: 2,
          key: 'firstClass.firstClassField',
        );

        final firstClassFirstClassFieldArray = NodeViewModelState.fromArray(
          treeDepth: 3,
          key: 'firstClass.firstClassField.array',
        );

        final firstClassFirstClassFieldArrayField =
            NodeViewModelState.fromProperty(
          treeDepth: 4,
          key: 'key',
          value: 'value',
          parent: firstClassFirstClassFieldArray,
        );

        firstClass.setNodeHierarchy(
          parent: null,
          children: firstClassFirstField,
        );

        firstClassFirstField.setNodeHierarchy(
          parent: firstClass,
          children: firstClassFirstClassField,
        );

        firstClassFirstClassField.setNodeHierarchy(
          parent: firstClassFirstField,
          children: firstClassFirstClassFieldArray,
        );

        firstClassFirstClassFieldArray.setNodeHierarchy(
          parent: firstClassFirstClassField,
          children: firstClassFirstClassFieldArrayField,
        );

        expect(firstClass.parent, isNull);
        expect(firstClassFirstField.parent, firstClass);
        expect(firstClassFirstClassField.parent, firstClassFirstField);
        expect(
          firstClassFirstClassFieldArray.parent,
          firstClassFirstClassField,
        );
        expect(
          firstClassFirstClassFieldArrayField.parent,
          firstClassFirstClassFieldArray,
        );
      });
    });
  });
}
