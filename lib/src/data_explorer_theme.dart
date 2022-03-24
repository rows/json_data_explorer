import 'package:flutter/material.dart';

/// Theme used to display the [JsonDataExplorer].
@immutable
class DataExplorerTheme {
  /// Text style use to display the keys of json attributes.
  final TextStyle? keyTextStyle;

  /// Text style to display the values of of json attributes.
  final TextStyle? valueTextStyle;

  /// Text style use to highlight search result matches on json attribute keys.
  final TextStyle? keySearchHighlightTextStyle;

  /// Text style use to highlight search result matches on json attribute
  /// values.
  final TextStyle? valueSearchHighlightTextStyle;

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
    this.keySearchHighlightTextStyle,
    this.valueTextStyle,
    this.valueSearchHighlightTextStyle,
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
    keySearchHighlightTextStyle: TextStyle(
      fontSize: 14,
      color: Colors.black,
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.amberAccent,
    ),
    valueSearchHighlightTextStyle: TextStyle(
      fontSize: 14,
      color: Colors.redAccent,
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.amberAccent,
    ),
  );

  DataExplorerTheme copyWith({
    TextStyle? keyTextStyle,
    TextStyle? keySearchHighlightTextStyle,
    TextStyle? valueTextStyle,
    TextStyle? valueSearchHighlightTextStyle,
    Color? indentationLineColor,
    Color? highlightColor,
    double? indentationPadding,
    double? propertyIndentationPaddingFactor,
  }) =>
      DataExplorerTheme(
        keyTextStyle: keyTextStyle ?? this.keyTextStyle,
        keySearchHighlightTextStyle:
            keySearchHighlightTextStyle ?? this.keySearchHighlightTextStyle,
        valueTextStyle: valueTextStyle ?? this.valueTextStyle,
        valueSearchHighlightTextStyle:
            keyTextStyle ?? this.valueSearchHighlightTextStyle,
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
            other.propertyIndentationPaddingFactor &&
        keySearchHighlightTextStyle == other.keySearchHighlightTextStyle &&
        valueSearchHighlightTextStyle == other.valueSearchHighlightTextStyle;
  }

  @override
  int get hashCode => Object.hash(
        keyTextStyle,
        valueTextStyle,
        indentationLineColor,
        highlightColor,
        indentationPadding,
        propertyIndentationPaddingFactor,
        keySearchHighlightTextStyle,
        valueSearchHighlightTextStyle,
      );
}
