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

  /// Padding used to indent nodes.
  final double indentationPadding;

  /// An extra factor applied on [indentationPadding] used when rendering
  /// properties.
  final double propertyIndentationPaddingFactor;

  /// Cursor hover highlight color.
  ///
  /// null to disable the highlight.
  final Color? highlightColor;

  const DataExplorerTheme({
    this.keyTextStyle,
    this.valueTextStyle,
    this.indentationLineColor = Colors.grey,
    this.highlightColor,
    this.indentationPadding = 8.0,
    this.propertyIndentationPaddingFactor = 4,
  });

  /// Default theme used if no theme is set.
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
    double? indentationPadding,
    double? propertyIndentationPaddingFactor,
  }) =>
      DataExplorerTheme(
        keyTextStyle: keyTextStyle ?? this.keyTextStyle,
        valueTextStyle: valueTextStyle ?? this.valueTextStyle,
        indentationLineColor: indentationLineColor ?? this.indentationLineColor,
        highlightColor: highlightColor ?? this.highlightColor,
        indentationPadding: indentationPadding ?? this.indentationPadding,
        propertyIndentationPaddingFactor: propertyIndentationPaddingFactor ??
            this.propertyIndentationPaddingFactor,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is DataExplorerTheme &&
        keyTextStyle == other.keyTextStyle &&
        valueTextStyle == other.valueTextStyle &&
        indentationLineColor == other.indentationLineColor &&
        highlightColor == other.highlightColor &&
        indentationPadding == other.indentationPadding &&
        propertyIndentationPaddingFactor ==
            other.propertyIndentationPaddingFactor;
  }

  @override
  int get hashCode => Object.hash(
        keyTextStyle,
        valueTextStyle,
        indentationLineColor,
        highlightColor,
        indentationPadding,
        propertyIndentationPaddingFactor,
      );
}
