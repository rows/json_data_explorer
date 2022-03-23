import 'package:flutter/material.dart';

/// Theme used to display the [JsonDataExplorer].
@immutable
class DataExplorerTheme {
  /// Text style use to display the keys of json attributes.
  final TextStyle? keyTextStyle;

  /// Text style to display the values of of json attributes.
  final TextStyle? valueTextStyle;

  /// Indentation lines color.
  final Color indentationLineColor;

  /// Cursor hover highlight color.
  ///
  /// null to disable the highlight.
  final Color? highlightColor;

  const DataExplorerTheme({
    this.keyTextStyle,
    this.valueTextStyle,
    this.indentationLineColor = Colors.grey,
    this.highlightColor,
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
    Color? indentationLineColor,
    Color? highlightColor,
  }) =>
      DataExplorerTheme(
        keyTextStyle: keyTextStyle ?? this.keyTextStyle,
        valueTextStyle: valueTextStyle ?? this.valueTextStyle,
        indentationLineColor: indentationLineColor ?? this.indentationLineColor,
        highlightColor: highlightColor ?? this.highlightColor,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is DataExplorerTheme &&
        keyTextStyle == other.keyTextStyle &&
        valueTextStyle == other.valueTextStyle &&
        indentationLineColor == other.indentationLineColor &&
        highlightColor == other.highlightColor;
  }

  @override
  int get hashCode => Object.hash(
        keyTextStyle,
        valueTextStyle,
        indentationLineColor,
        highlightColor,
      );
}
