import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data_explorer_store.dart';
import 'data_explorer_theme.dart';

/// Signature for a function that creates a widget based on a
/// [NodeViewModelState] state.
typedef NodeBuilder = Widget Function(
  BuildContext context,
  NodeViewModelState node,
);

/// Signature for a function that takes a generic value and converts it to a
/// string.
typedef Formatter = String Function(dynamic value);

/// A widget to display a list of Json nodes.
///
/// The [DataExplorerStore] handles the state of the data structure, so a
/// [DataExplorerStore] must be available through a [Provider] for this widget
/// to fully function, without it, expand and collapse will not work properly.
///
/// {@tool snippet}
/// ```dart
/// DataExplorerStore store;
/// // ...
/// ChangeNotifierProvider.value(
///   value: store,
///   child:
/// // ...
/// ```
///
/// And then a [JsonDataExplorer] can be built using the store data structure:
/// {@tool snippet}
/// ```dart
/// Widget build(BuildContext context) {
///   return Scaffold(
///     appBar: AppBar(
///       title: Text(widget.title),
///     ),
///     body: SafeArea(
///       minimum: const EdgeInsets.all(16),
///       child: ChangeNotifierProvider.value(
///         value: store,
///         child: Consumer<DataExplorerStore>(
///           builder: (context, state, child) => JsonDataExplorer(
///             nodes: state.displayNodes,
///           ),
///         ),
///       ),
///     ),
///   );
/// }
/// ```
/// {@end-tool}
class JsonDataExplorer extends StatelessWidget {
  /// Nodes to be displayed.
  ///
  /// See also:
  /// * [DataExplorerStore]
  final Iterable<NodeViewModelState> nodes;

  /// Use to control the scroll.
  ///
  /// Used to jump or scroll to a particular position.
  final ItemScrollController? itemScrollController;

  /// Use to listen to scroll position changes.
  final ItemPositionsListener? itemPositionsListener;

  /// Theme used to render the widgets.
  ///
  /// If not set, a default theme will be used.
  final DataExplorerTheme theme;

  /// A builder to add a widget as a suffix for root nodes.
  ///
  /// This can be used to display useful information such as the number of
  /// children nodes, or to indicate if the node is class or an array
  /// for example.
  final NodeBuilder? rootInformationBuilder;

  /// Build the expand/collapse icons in root nodes.
  ///
  /// If this builder is null, a material [Icons.arrow_right] is displayed for
  /// collapsed nodes and [Icons.arrow_drop_down] for expanded nodes.
  final NodeBuilder? collapsableToggleBuilder;

  /// A builder to add a trailing widget in each node.
  ///
  /// This widget is added to the end of the node on top of the content.
  final NodeBuilder? trailingBuilder;

  /// Customizes how class/array names are formatted as string.
  ///
  /// By default the class and array names are displayed as follows: 'name:'
  final Formatter? rootNameFormatter;

  /// Customizes how property names are formatted as string.
  ///
  /// By default the property names are displayed as follows: 'name:'
  final Formatter? propertyNameFormatter;

  /// Customizes how property values are formatted as string.
  ///
  /// By default the value is converted to a string by calling the .toString()
  /// method.
  final Formatter? valueFormatter;

  /// Sets the spacing between each list item.
  final double itemSpacing;

  const JsonDataExplorer({
    Key? key,
    required this.nodes,
    this.itemScrollController,
    this.itemPositionsListener,
    this.rootInformationBuilder,
    this.collapsableToggleBuilder,
    this.trailingBuilder,
    this.rootNameFormatter,
    this.propertyNameFormatter,
    this.valueFormatter,
    this.itemSpacing = 2,
    DataExplorerTheme? theme,
  })  : theme = theme ?? DataExplorerTheme.defaultTheme,
        super(key: key);

  @override
  Widget build(BuildContext context) => ScrollablePositionedList.builder(
        itemCount: nodes.length,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        itemBuilder: (context, index) => AnimatedBuilder(
          animation: nodes.elementAt(index),
          builder: (context, child) => DecoratedBox(
            decoration: BoxDecoration(
              color: nodes.elementAt(index).isHighlighted
                  ? theme.highlightColor
                  : null,
            ),
            child: child,
          ),
          child: _JsonAttribute(
            node: nodes.elementAt(index),
            rootInformationBuilder: rootInformationBuilder,
            collapsableToggleBuilder: collapsableToggleBuilder,
            trailingBuilder: trailingBuilder,
            rootNameFormatter: rootNameFormatter,
            propertyNameFormatter: propertyNameFormatter,
            valueFormatter: valueFormatter,
            itemSpacing: itemSpacing,
            theme: theme,
          ),
        ),
      );
}

class _JsonAttribute extends StatelessWidget {
  /// Node to be displayed.
  final NodeViewModelState node;

  /// A builder to add a widget as a suffix for root nodes.
  ///
  /// This can be used to display useful information such as the number of
  /// children nodes, or to indicate if the node is class or an array
  /// for example.
  final NodeBuilder? rootInformationBuilder;

  /// Build the expand/collapse icons in root nodes.
  ///
  /// If this builder is null, a material [Icons.arrow_right] is displayed for
  /// collapsed nodes and [Icons.arrow_drop_down] for expanded nodes.
  final NodeBuilder? collapsableToggleBuilder;

  /// A builder to add a trailing widget in each node.
  ///
  /// This widget is added to the end of the node on top of the content.
  final NodeBuilder? trailingBuilder;

  /// Customizes how class/array names are formatted as string.
  ///
  /// By default the class and array names are displayed as follows: 'name:'
  final Formatter? rootNameFormatter;

  /// Customizes how property names are formatted as string.
  ///
  /// By default the property names are displayed as follows: 'name:'
  final Formatter? propertyNameFormatter;

  /// Customizes how property values are formatted as string.
  ///
  /// By default the value is converted to a string by calling the .toString()
  /// method.
  final Formatter? valueFormatter;

  /// Sets the spacing between each list item.
  final double itemSpacing;

  /// Theme used to render this widget.
  final DataExplorerTheme theme;

  const _JsonAttribute({
    Key? key,
    required this.node,
    required this.theme,
    this.rootInformationBuilder,
    this.collapsableToggleBuilder,
    this.trailingBuilder,
    this.rootNameFormatter,
    this.propertyNameFormatter,
    this.valueFormatter,
    this.itemSpacing = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final valueIsUrl = _valueIsUrl();
    final searchTerm =
        context.select<DataExplorerStore, String>((store) => store.searchTerm);
    final isKeySearchFocused = context.select<DataExplorerStore, bool>(
      (store) => store.searchResults.isNotEmpty
          ? store.focusedSearchResult.node == node &&
              store.focusedSearchResult.key
          : false,
    );
    final isValueSearchFocused = context.select<DataExplorerStore, bool>(
      (store) => store.searchResults.isNotEmpty
          ? store.focusedSearchResult.node == node &&
              store.focusedSearchResult.value
          : false,
    );

    final attributeKeyStyle =
        node.isRoot ? theme.rootKeyTextStyle : theme.propertyKeyTextStyle;

    final spacing = itemSpacing / 2;

    return MouseRegion(
      cursor: node.isRoot || valueIsUrl
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (event) {
        node.highlight();
        node.focus();
      },
      onExit: (event) {
        node.highlight(isHighlighted: false);
        node.focus(isFocused: false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: node.isRoot || valueIsUrl ? () => _onTap(context) : null,
        child: AnimatedBuilder(
          animation: node,

          /// IntrinsicHeight is not the best solution for this, the performance
          /// hit that we measured is ok for now. We will revisit this in the
          /// future if we fill that we need to improve the node rendering
          /// performance
          builder: (context, child) => Stack(
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: node.isRoot
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    _Indentation(
                      node: node,
                      indentationPadding: theme.indentationPadding,
                      propertyPaddingFactor:
                          theme.propertyIndentationPaddingFactor,
                      lineColor: theme.indentationLineColor,
                    ),
                    if (node.isRoot)
                      SizedBox(
                        width: 24,
                        child: collapsableToggleBuilder?.call(context, node) ??
                            _defaultCollapsableToggleBuilder(context, node),
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: spacing),
                      child: _HighlightedText(
                        text: _keyName(),
                        highlightedText: searchTerm,
                        style: attributeKeyStyle,
                        highlightedStyle: isKeySearchFocused
                            ? theme.focusedKeySearchNodeHighlightTextStyle
                            : theme.keySearchHighlightTextStyle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (node.isRoot)
                      rootInformationBuilder?.call(context, node) ??
                          const SizedBox()
                    else
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: spacing),
                          child: _HighlightedText(
                            text: valueFormatter?.call(node.value) ??
                                node.value.toString(),
                            highlightedText: searchTerm,
                            style: valueIsUrl
                                ? theme.valueTextStyle.copyWith(
                                    decoration: TextDecoration.underline,
                                  )
                                : theme.valueTextStyle,
                            highlightedStyle: isValueSearchFocused
                                ? theme.focusedValueSearchHighlightTextStyle
                                : theme.valueSearchHighlightTextStyle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (trailingBuilder != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: trailingBuilder!.call(context, node),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future _onTap(BuildContext context) async {
    if (_valueIsUrl()) {
      return launch(node.value as String);
    }
    if (node.isRoot) {
      final dataExplorerStore = Provider.of<DataExplorerStore>(
        context,
        listen: false,
      );
      if (node.isCollapsed) {
        dataExplorerStore.expandNode(node);
      } else {
        dataExplorerStore.collapseNode(node);
      }
    }
  }

  String _keyName() {
    if (node.isRoot) {
      return rootNameFormatter?.call(node.key) ?? '${node.key}:';
    }
    return propertyNameFormatter?.call(node.key) ?? '${node.key}:';
  }

  bool _valueIsUrl() {
    if (node.value is String) {
      return Uri.tryParse(node.value as String)?.hasAbsolutePath ?? false;
    }
    return false;
  }

  /// Default value for [collapsableToggleBuilder]
  ///
  /// A material [Icons.arrow_right] is displayed for collapsed nodes and
  /// [Icons.arrow_drop_down] for expanded nodes.
  static Widget _defaultCollapsableToggleBuilder(
    BuildContext context,
    NodeViewModelState node,
  ) =>
      node.isCollapsed
          ? const Icon(
              Icons.arrow_right,
            )
          : const Icon(
              Icons.arrow_drop_down,
            );
}

/// Creates the indentation lines and padding of each node depending on its
/// [node.treeDepth] and whether or not the node is a root node.
class _Indentation extends StatelessWidget {
  /// Current node view model
  final NodeViewModelState node;

  /// The padding of each indentation, this change the spacing between each
  /// [node.treeDepth] and the spacing between lines.
  final double indentationPadding;

  /// Color used to render the indentation lines.
  final Color lineColor;

  /// A padding factor to be applied on non root nodes, so its properties have
  /// extra padding steps.
  final double propertyPaddingFactor;

  const _Indentation({
    Key? key,
    required this.node,
    required this.indentationPadding,
    this.lineColor = Colors.grey,
    this.propertyPaddingFactor = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const lineWidth = 1.0;
    return Row(
      children: [
        for (int i = 0; i < node.treeDepth; i++)
          Container(
            margin: EdgeInsets.only(
              right: indentationPadding,
            ),
            width: lineWidth,
            color: lineColor,
          ),
        if (!node.isRoot)
          SizedBox(
            width: node.treeDepth > 0
                ? indentationPadding * propertyPaddingFactor
                : indentationPadding,
          ),
        if (node.isRoot && !node.isCollapsed) ...[
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.52,
              child: Container(
                width: 1,
                color: lineColor,
              ),
            ),
          ),
          Container(
            height: lineWidth,
            width: (indentationPadding / 2) - lineWidth,
            color: lineColor,
          ),
        ],
        if (node.isRoot && node.isCollapsed)
          SizedBox(
            width: indentationPadding / 2,
          ),
      ],
    );
  }
}

/// Highlights found occurrences of [highlightedText] with [highlightedStyle]
/// in [text].
class _HighlightedText extends StatelessWidget {
  final String text;
  final String highlightedText;
  final TextStyle style;
  final TextStyle highlightedStyle;

  const _HighlightedText({
    Key? key,
    required this.text,
    required this.highlightedText,
    required this.style,
    required this.highlightedStyle,
  }) : super(key: key);

  bool _ignoreHighlightedText() {
    return highlightedText == ':' && text.lastIndexOf(':') == text.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final lowerCaseText = text.toLowerCase();
    final lowerCaseQuery = highlightedText.toLowerCase();
    if (highlightedText.isEmpty ||
        !lowerCaseText.contains(lowerCaseQuery) ||
        _ignoreHighlightedText()) {
      return Text(text, style: style);
    }

    final spans = <TextSpan>[];
    var start = 0;

    while (true) {
      var index = lowerCaseText.indexOf(lowerCaseQuery, start);
      index = index >= 0 ? index : text.length;

      if (start != index) {
        spans.add(
          TextSpan(
            text: text.substring(start, index),
            style: style,
          ),
        );
      }

      if (index >= text.length) {
        break;
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + highlightedText.length),
          style: highlightedStyle,
        ),
      );
      start = index + highlightedText.length;
    }

    return RichText(
      text: TextSpan(
        children: spans,
      ),
    );
  }
}
