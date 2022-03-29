import 'package:flutter_test/flutter_test.dart';
import 'package:json_data_explorer/json_data_explorer.dart';
import 'package:mocktail/mocktail.dart';

class MockCallbackFunction extends Mock {
  call();
}

void main() {
  group('NodeViewModelState', () {
    group('Property', () {
      test('build as a property', () {
        final viewModel = NodeViewModelState.fromProperty(
          treeDepth: 1,
          key: 'key',
          value: 123,
        );

        expect(viewModel.key, 'key');
        expect(viewModel.value, isA<int>());
        expect(viewModel.value, 123);
        expect(viewModel.isRoot, isFalse);
        expect(viewModel.isClass, isFalse);
        expect(viewModel.isArray, isFalse);
        expect(viewModel.isHighlighted, isFalse);
        expect(viewModel.isCollapsed, isFalse);
      });

      test('a property has no children nodes', () {
        final viewModel = NodeViewModelState.fromProperty(
          treeDepth: 1,
          key: 'key',
          value: 123,
        );
        expect(viewModel.childrenCount, 0);
        expect(viewModel.children, hasLength(0));
      });

      test('highlight notifies listeners', () {
        final viewModel = NodeViewModelState.fromProperty(
          treeDepth: 1,
          key: 'key',
          value: 123,
        );
        final listener = MockCallbackFunction();
        viewModel.addListener(listener);

        viewModel.highlight(true);
        expect(viewModel.isHighlighted, isTrue);

        viewModel.highlight(false);
        expect(viewModel.isHighlighted, isFalse);
        verify(() => listener.call()).called(2);
      });

      test('collapse notifies listeners', () {
        final viewModel = NodeViewModelState.fromProperty(
          treeDepth: 1,
          key: 'key',
          value: 123,
        );
        final listener = MockCallbackFunction();
        viewModel.addListener(listener);

        viewModel.collapse();
        expect(viewModel.isCollapsed, isTrue);

        viewModel.expand();
        expect(viewModel.isCollapsed, isFalse);
        verify(() => listener.call()).called(2);
      });
    });

    group('Class', () {
      test('build as a class', () {
        final classMap = {
          'propertyA': NodeViewModelState.fromProperty(
            treeDepth: 1,
            key: 'propertyA',
            value: 123,
          ),
          'propertyB': NodeViewModelState.fromProperty(
            treeDepth: 1,
            key: 'propertyB',
            value: 'string',
          ),
        };

        final viewModel = NodeViewModelState.fromClass(
          treeDepth: 0,
          key: 'classKey',
          value: classMap,
        );

        expect(viewModel.key, 'classKey');
        expect(viewModel.value, isA<Map<String, NodeViewModelState>>());
        expect(viewModel.value, hasLength(2));
        expect(viewModel.isRoot, isTrue);
        expect(viewModel.isClass, isTrue);
        expect(viewModel.isArray, isFalse);
        expect(viewModel.isHighlighted, isFalse);
        expect(viewModel.isCollapsed, isFalse);
      });

      test('children nodes', () {
        final classMap = {
          'propertyA': NodeViewModelState.fromProperty(
            treeDepth: 1,
            key: 'propertyA',
            value: 123,
          ),
          'propertyB': NodeViewModelState.fromProperty(
            treeDepth: 1,
            key: 'propertyB',
            value: 'string',
          ),
        };

        final viewModel = NodeViewModelState.fromClass(
          treeDepth: 0,
          key: 'classKey',
          value: classMap,
        );

        expect(viewModel.childrenCount, 2);
        expect(viewModel.children, hasLength(2));
        expect(viewModel.children.elementAt(0).key, 'propertyA');
        expect(viewModel.children.elementAt(1).key, 'propertyB');
      });

      test('highlight sets highlight in all children', () {
        final classMap = {
          'property': NodeViewModelState.fromProperty(
            treeDepth: 1,
            key: 'property',
            value: 123,
          ),
          'innerClass': NodeViewModelState.fromClass(
            treeDepth: 1,
            key: 'innerClass',
            value: {
              'innerClassProperty': NodeViewModelState.fromProperty(
                treeDepth: 2,
                key: 'innerClassProperty',
                value: 123,
              ),
            },
          ),
        };

        final viewModel = NodeViewModelState.fromClass(
          treeDepth: 0,
          key: 'classKey',
          value: classMap,
        );

        viewModel.highlight(true);
        expect(viewModel.isHighlighted, isTrue);
        expect(classMap['property']!.isHighlighted, isTrue);
        expect(classMap['innerClass']!.isHighlighted, isTrue);
        expect(
          classMap['innerClass']!.value['innerClassProperty']!.isHighlighted,
          isTrue,
        );

        viewModel.highlight(false);
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
        final arrayValues = [
          NodeViewModelState.fromProperty(
            treeDepth: 1,
            key: '0',
            value: 123,
          ),
          NodeViewModelState.fromProperty(
            treeDepth: 1,
            key: '1',
            value: 'string',
          ),
        ];

        final viewModel = NodeViewModelState.fromArray(
          treeDepth: 0,
          key: 'arrayKey',
          value: arrayValues,
        );

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
        final arrayValues = [
          NodeViewModelState.fromProperty(
            treeDepth: 1,
            key: '0',
            value: 123,
          ),
          NodeViewModelState.fromProperty(
            treeDepth: 1,
            key: '1',
            value: 'string',
          ),
        ];

        final viewModel = NodeViewModelState.fromArray(
          treeDepth: 0,
          key: 'arrayKey',
          value: arrayValues,
        );

        expect(viewModel.childrenCount, 2);
        expect(viewModel.children, hasLength(2));
        expect(viewModel.children.elementAt(0).key, '0');
        expect(viewModel.children.elementAt(1).key, '1');
      });

      test('highlight sets highlight in all children', () {
        final arrayValues = [
          NodeViewModelState.fromClass(
            treeDepth: 1,
            key: 'class',
            value: {
              'classProperty': NodeViewModelState.fromProperty(
                treeDepth: 2,
                key: 'classProperty',
                value: 123,
              ),
            },
          ),
        ];
        final viewModel = NodeViewModelState.fromArray(
          treeDepth: 0,
          key: 'arrayKey',
          value: arrayValues,
        );

        viewModel.highlight(true);
        expect(viewModel.isHighlighted, isTrue);
        expect(arrayValues[0].isHighlighted, isTrue);
        expect(arrayValues[0].value['classProperty']!.isHighlighted, isTrue);

        viewModel.highlight(false);
        expect(viewModel.isHighlighted, isFalse);
        expect(arrayValues[0].isHighlighted, isFalse);
        expect(arrayValues[0].value['classProperty']!.isHighlighted, isFalse);
      });
    });
  });
}
