import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:json_data_explorer/json_data_explorer.dart';
import 'package:provider/provider.dart';

import 'test_data.dart';

void main() {
  testGoldens('Tree should look correct on multiple device sizes',
      (tester) async {
    final dynamic jsonObject = json.decode(nobelPrizesJson);

    final builder = DeviceBuilder()
      ..overrideDevicesForAllScenarios(
        devices: [
          Device.phone,
          Device.iphone11,
          Device.tabletPortrait,
          Device.tabletLandscape,
        ],
      )
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
      );

    await tester.pumpDeviceBuilder(builder);
    await screenMatchesGolden(tester, 'multi_size_test');
  });
}
