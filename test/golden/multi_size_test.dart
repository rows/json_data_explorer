import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:json_data_explorer/json_data_explorer.dart';
import 'package:provider/provider.dart';

import 'test_data.dart';

void main() {
  testGoldens('Weather types should look correct', (tester) async {
    final jsonObject = json.decode(nobelPrizesJson);

    final widget = ChangeNotifierProvider(
      create: (context) => DataExplorerStore()..buildNodes(jsonObject),
      child: Consumer<DataExplorerStore>(
        builder: (context, state, child) => JsonDataExplorer(
          nodes: state.displayNodes,
        ),
      ),
    );

    final builder = DeviceBuilder()
      ..overrideDevicesForAllScenarios(devices: [
        Device.phone,
        Device.iphone11,
        Device.tabletPortrait,
        Device.tabletLandscape,
      ])
      ..addScenario(
        name: 'default theme',
        widget: ChangeNotifierProvider(
          create: (context) => DataExplorerStore()..buildNodes(jsonObject),
          child: Consumer<DataExplorerStore>(
            builder: (context, state, child) => JsonDataExplorer(
              nodes: state.displayNodes,
            ),
          ),
        ),
      )
      ..addScenario(
        name: 'custom theme',
        widget: ChangeNotifierProvider(
          create: (context) => DataExplorerStore()..buildNodes(jsonObject),
          child: Consumer<DataExplorerStore>(
            builder: (context, state, child) => JsonDataExplorer(
              nodes: state.displayNodes,
              theme: DataExplorerTheme(
                rootKeyTextStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                propertyKeyTextStyle: TextStyle(
                  color: Colors.black.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                valueTextStyle: const TextStyle(
                  color: Color(0xFFCA442C),
                  fontSize: 18,
                ),
                indentationLineColor: const Color(0xFF515151),
                highlightColor: const Color(0xFFF1F1F1),
              ),
            ),
          ),
        ),
      )
      ..addScenario(
          name: 'highlight entire node on hover',
          widget: ChangeNotifierProvider(
            create: (context) => DataExplorerStore()..buildNodes(jsonObject),
            child: Consumer<DataExplorerStore>(
              builder: (context, state, child) => JsonDataExplorer(
                nodes: state.displayNodes,
              ),
            ),
          ),
          onCreate: (widgetKey) async {
            final gesture = await tester.createGesture(
              kind: PointerDeviceKind.mouse,
            );
            await gesture.addPointer(location: Offset.zero);
            addTearDown(gesture.removePointer);
            await tester.pump();

            final finder = find.descendant(
              of: find.byKey(widgetKey),
              matching: find.text(
                'laureates:',
                findRichText: true,
              ),
            );
            await gesture.moveTo(tester.getCenter(finder.first));
            await tester.pumpAndSettle();
          });

    await tester.pumpDeviceBuilder(builder);
    await screenMatchesGolden(tester, 'multi_size_test');
  });
}
