// ignore_for_file: avoid_private_typedef_functions
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:json_data_explorer/json_data_explorer.dart';
import 'package:provider/provider.dart';

import 'test_data.dart';

typedef _NodeBuilder = Widget Function(int treeDepth, DataExplorerTheme theme);

void main() {
  testGoldens('Json attribute', (tester) async {
    final dynamic jsonObject = json.decode(nobelPrizesJson);

    final node = NodeViewModelState.fromProperty(
      treeDepth: 0,
      key: 'property',
      value: 'value',
    );

    final widget = ChangeNotifierProvider(
      create: (context) => DataExplorerStore()..buildNodes(jsonObject),
      child: Consumer<DataExplorerStore>(
        builder: (context, state, child) => JsonAttribute(
          node: node,
          theme: DataExplorerTheme.defaultTheme,
        ),
      ),
    );

    final builder = GoldenBuilder.column(bgColor: Colors.white)
      ..addScenario('Default font size', widget)
      ..addTextScaleScenario('Large font size', widget, textScaleFactor: 2.0)
      ..addTextScaleScenario('Largest font', widget, textScaleFactor: 3.0);

    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'json_attribute');
  });

  group('Indentation', () {
    Future testIndentationGuidelines(
      WidgetTester tester, {
      required _NodeBuilder nodeBuilder,
      required String goldenName,
    }) async {
      final builder = GoldenBuilder.column(bgColor: Colors.white)
        ..addScenario(
          'no indentation',
          nodeBuilder(0, DataExplorerTheme.defaultTheme),
        )
        ..addScenario(
          '1 step',
          nodeBuilder(1, DataExplorerTheme.defaultTheme),
        )
        ..addScenario(
          '2 steps',
          nodeBuilder(2, DataExplorerTheme.defaultTheme),
        )
        ..addScenario(
          '3 steps',
          nodeBuilder(3, DataExplorerTheme.defaultTheme),
        )
        ..addScenario(
          '4 steps',
          nodeBuilder(4, DataExplorerTheme.defaultTheme),
        )
        ..addScenario(
          'custom color',
          nodeBuilder(
            4,
            DataExplorerTheme(
              indentationLineColor: Colors.blue,
            ),
          ),
        )
        ..addScenario(
          'no guidelines',
          nodeBuilder(
            4,
            DataExplorerTheme(
              indentationLineColor: Colors.transparent,
            ),
          ),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        wrapper: (widget) => materialAppWrapper()(
          ChangeNotifierProvider(
            create: (context) => DataExplorerStore(),
            child: Consumer<DataExplorerStore>(
              builder: (context, state, child) => widget,
            ),
          ),
        ),
        surfaceSize: const Size(200, 600),
      );
      await screenMatchesGolden(tester, 'indentation/$goldenName');
    }

    testGoldens('Property indentation guidelines', (tester) async {
      await testIndentationGuidelines(
        tester,
        goldenName: 'property_indentation',
        nodeBuilder: (treeDepth, theme) {
          final node = NodeViewModelState.fromProperty(
            treeDepth: treeDepth,
            key: 'property',
            value: 'value',
          );
          return JsonAttribute(
            node: node,
            theme: theme,
          );
        },
      );
    });

    testGoldens('Property indentation guidelines', (tester) async {
      await testIndentationGuidelines(
        tester,
        goldenName: 'class_indentation',
        nodeBuilder: (treeDepth, theme) {
          final node = NodeViewModelState.fromClass(
            treeDepth: treeDepth,
            key: 'class',
            value: {},
          );
          return JsonAttribute(
            node: node,
            theme: theme,
          );
        },
      );
    });

    testGoldens('Array indentation guidelines', (tester) async {
      await testIndentationGuidelines(
        tester,
        goldenName: 'array_indentation',
        nodeBuilder: (treeDepth, theme) {
          final node = NodeViewModelState.fromArray(
            treeDepth: treeDepth,
            key: 'array',
            value: <dynamic>[],
          );
          return JsonAttribute(
            node: node,
            theme: theme,
          );
        },
      );
    });
  });
}
