import 'package:flutter/material.dart';

/// Theme used to display the [JsonDataExplorer].
@immutable
class DataExplorerTheme {
  /// Text style use to display the keys of json attributes.
  final TextStyle? keyTextStyle;

  /// Text style to display the values of of json attributes.
  final TextStyle? valueTextStyle;

  /// Color of the indentation lines.
  final Color indentationLineColor;

  const DataExplorerTheme({
    this.keyTextStyle,
    this.valueTextStyle,
    this.indentationLineColor = Colors.grey,
  });

  static const defaultTheme = DataExplorerTheme(
    keyTextStyle: TextStyle(
      fontSize: 14,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    valueTextStyle: TextStyle(
      fontSize: 14,
      color: Colors.redAccent,
    ),
  );

  DataExplorerTheme copyWith({
    TextStyle? keyTextStyle,
    TextStyle? valueTextStyle,
  }) =>
      DataExplorerTheme(
        keyTextStyle: keyTextStyle ?? this.keyTextStyle,
        valueTextStyle: valueTextStyle ?? this.valueTextStyle,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is DataExplorerTheme &&
        keyTextStyle == other.keyTextStyle &&
        valueTextStyle == other.valueTextStyle &&
        indentationLineColor == other.indentationLineColor;
  }

  @override
  int get hashCode => Object.hash(
        keyTextStyle,
        valueTextStyle,
        indentationLineColor,
      );
}
