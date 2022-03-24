import 'package:flutter/material.dart';

/// Theme used to display the [JsonDataExplorer].
@immutable
class DataExplorerTheme {
  /// Text style used to display json class/arrays key attributes.
  ///
  /// Defaults to [propertyKeyTextStyle] if not set.
  final TextStyle rootKeyTextStyle;

  /// Text style used to display json property key attributes.
  final TextStyle propertyKeyTextStyle;

  /// Text style to display the values of of json attributes.
  final TextStyle valueTextStyle;

  /// Text style use to highlight search result matches on json attribute keys.
  final TextStyle keySearchHighlightTextStyle;

  /// Text style use to highlight search result matches on json attribute
  /// values.
  final TextStyle valueSearchHighlightTextStyle;

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

  DataExplorerTheme({
    TextStyle? rootKeyTextStyle,
    TextStyle? propertyKeyTextStyle,
    TextStyle? keySearchHighlightTextStyle,
    TextStyle? valueTextStyle,
    TextStyle? valueSearchHighlightTextStyle,
    this.indentationLineColor = Colors.grey,
    this.highlightColor,
    this.indentationPadding = 8.0,
    this.propertyIndentationPaddingFactor = 4,
  })  : rootKeyTextStyle = rootKeyTextStyle ??
            (propertyKeyTextStyle ??
                DataExplorerTheme.defaultTheme.rootKeyTextStyle),
        propertyKeyTextStyle = propertyKeyTextStyle ??
            DataExplorerTheme.defaultTheme.rootKeyTextStyle,
        keySearchHighlightTextStyle = keySearchHighlightTextStyle ??
            DataExplorerTheme.defaultTheme.keySearchHighlightTextStyle,
        valueTextStyle =
            valueTextStyle ?? DataExplorerTheme.defaultTheme.valueTextStyle,
        valueSearchHighlightTextStyle = valueSearchHighlightTextStyle ??
            DataExplorerTheme.defaultTheme.valueSearchHighlightTextStyle;

  const DataExplorerTheme._({
    required this.rootKeyTextStyle,
    required this.propertyKeyTextStyle,
    required this.keySearchHighlightTextStyle,
    required this.valueTextStyle,
    required this.valueSearchHighlightTextStyle,
    this.indentationLineColor = Colors.grey,
    this.highlightColor,
    this.indentationPadding = 8.0,
    this.propertyIndentationPaddingFactor = 4,
  });

  /// Default theme used if no theme is set.
  static const defaultTheme = DataExplorerTheme._(
    rootKeyTextStyle: TextStyle(
      fontSize: 14,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    propertyKeyTextStyle: TextStyle(
      fontSize: 14,
      color: Colors.black54,
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
    TextStyle? rootKeyTextStyle,
    TextStyle? propertyKeyTextStyle,
    TextStyle? keySearchHighlightTextStyle,
    TextStyle? valueTextStyle,
    TextStyle? valueSearchHighlightTextStyle,
    Color? indentationLineColor,
    Color? highlightColor,
    double? indentationPadding,
    double? propertyIndentationPaddingFactor,
  }) =>
      DataExplorerTheme(
        rootKeyTextStyle: rootKeyTextStyle ?? this.rootKeyTextStyle,
        propertyKeyTextStyle: propertyKeyTextStyle ?? this.propertyKeyTextStyle,
        keySearchHighlightTextStyle:
            keySearchHighlightTextStyle ?? this.keySearchHighlightTextStyle,
        valueTextStyle: valueTextStyle ?? this.valueTextStyle,
        valueSearchHighlightTextStyle:
            valueSearchHighlightTextStyle ?? this.valueSearchHighlightTextStyle,
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
        rootKeyTextStyle == other.rootKeyTextStyle &&
        propertyKeyTextStyle == other.propertyKeyTextStyle &&
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
        rootKeyTextStyle,
        propertyKeyTextStyle,
        valueTextStyle,
        indentationLineColor,
        highlightColor,
        indentationPadding,
        propertyIndentationPaddingFactor,
        keySearchHighlightTextStyle,
        valueSearchHighlightTextStyle,
      );
}
