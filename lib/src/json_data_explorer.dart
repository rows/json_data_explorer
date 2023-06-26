import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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

/// Signature for a function that takes a generic value and the current theme
/// property value style and returns a [StyleBuilder] that allows the style
/// and interaction to be changed dynamically.
///
/// See also:
/// * [PropertyStyle]
typedef StyleBuilder = PropertyOverrides Function(
  NodeViewModelState node,
  dynamic value,
  TextStyle style,
);

/// Holds information about a property value style and interaction.
class PropertyOverrides {
  final TextStyle? style;
  final VoidCallback? onTap;
  final VoidCallback? onSecondaryTap;
  final VoidCallback? onLongPress;
  final MouseCursor? cursor;

  const PropertyOverrides({
    this.style,
    this.onTap,
    this.onSecondaryTap,
    this.onLongPress,
    this.cursor,
  });
}

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

  /// Customizes a property style and interaction based on its value.
  ///
  /// See also:
  /// * [StyleBuilder]
  final StyleBuilder? valueStyleBuilder;

  /// Sets the spacing between each list item.
  final double itemSpacing;

  /// Sets the scroll physics of the list.
  final ScrollPhysics? physics;

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
    this.valueStyleBuilder,
    this.itemSpacing = 2,
    this.physics,
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
          child: JsonAttribute(
            node: nodes.elementAt(index),
            rootInformationBuilder: rootInformationBuilder,
            collapsableToggleBuilder: collapsableToggleBuilder,
            trailingBuilder: trailingBuilder,
            rootNameFormatter: rootNameFormatter,
            propertyNameFormatter: propertyNameFormatter,
            valueFormatter: valueFormatter,
            valueStyleBuilder: valueStyleBuilder,
            itemSpacing: itemSpacing,
            theme: theme,
          ),
        ),
        physics: physics,
      );
}

class JsonAttribute extends StatelessWidget {
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

  /// Customizes a property style and interaction based on its value.
  ///
  /// See also:
  /// * [StyleBuilder]
  final StyleBuilder? valueStyleBuilder;

  /// Sets the spacing between each list item.
  final double itemSpacing;

  /// Theme used to render this widget.
  final DataExplorerTheme theme;

  const JsonAttribute({
    Key? key,
    required this.node,
    required this.theme,
    this.rootInformationBuilder,
    this.collapsableToggleBuilder,
    this.trailingBuilder,
    this.rootNameFormatter,
    this.propertyNameFormatter,
    this.valueFormatter,
    this.valueStyleBuilder,
    this.itemSpacing = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchTerm =
        context.select<DataExplorerStore, String>((store) => store.searchTerm);

    final spacing = itemSpacing / 2;

    final valueStyle = valueStyleBuilder != null
        ? valueStyleBuilder!.call(
            node,
            node.value,
            theme.valueTextStyle,
          )
        : const PropertyOverrides();

    final hasInteraction = node.isRoot || valueStyle.onTap != null;

    return MouseRegion(
      cursor: valueStyle.cursor != null
          ? valueStyle.cursor!
          : (hasInteraction ? SystemMouseCursors.click : MouseCursor.defer),
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
        onTap: hasInteraction
            ? () {
                if (valueStyle.onTap != null) {
                  valueStyle.onTap!.call();
                } else {
                  _onTap(context);
                }
              }
            : null,
        onLongPress: valueStyle.onLongPress,
        onSecondaryTap: valueStyle.onSecondaryTap,
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
                      child: _RootNodeWidget(
                        node: node,
                        rootNameFormatter: rootNameFormatter,
                        propertyNameFormatter: propertyNameFormatter,
                        searchTerm: searchTerm,
                        theme: theme,
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
                          child: _PropertyNodeWidget(
                            node: node,
                            searchTerm: searchTerm,
                            valueFormatter: valueFormatter,
                            style: valueStyle.style ?? theme.valueTextStyle,
                            searchHighlightStyle:
                                theme.valueSearchHighlightTextStyle,
                            focusedSearchHighlightStyle:
                                theme.focusedValueSearchHighlightTextStyle,
                            highlightOnlyRegExpGroups:
                                theme.highlightOnlyRegExpGroups,
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

/// A [Widget] that renders a node that can be a class or a list.
class _RootNodeWidget extends StatelessWidget {
  final NodeViewModelState node;
  final String searchTerm;
  final Formatter? rootNameFormatter;
  final Formatter? propertyNameFormatter;
  final DataExplorerTheme theme;

  const _RootNodeWidget({
    Key? key,
    required this.node,
    required this.searchTerm,
    required this.rootNameFormatter,
    required this.propertyNameFormatter,
    required this.theme,
  }) : super(key: key);

  String _keyName() {
    if (node.isRoot) {
      return rootNameFormatter?.call(node.key) ?? '${node.key}:';
    }
    return propertyNameFormatter?.call(node.key) ?? '${node.key}:';
  }

  /// Gets the index of the focused search match.
  int? _getFocusedSearchMatchIndex(DataExplorerStore store) {
    if (store.searchResults.isEmpty) {
      return null;
    }

    if (store.focusedSearchResult.node != node) {
      return null;
    }

    // Assert that it's the key and not the value of the node.
    if (store.focusedSearchResult.matchLocation != SearchMatchLocation.key) {
      return null;
    }

    return store.focusedSearchResult.matchIndex;
  }

  @override
  Widget build(BuildContext context) {
    final showHighlightedText = context.select<DataExplorerStore, bool>(
      (store) => store.searchResults.isNotEmpty,
    );

    final attributeKeyStyle =
        node.isRoot ? theme.rootKeyTextStyle : theme.propertyKeyTextStyle;

    final text = _keyName();

    if (!showHighlightedText) {
      return Text(text, style: attributeKeyStyle);
    }

    final focusedSearchMatchIndex =
        context.select<DataExplorerStore, int?>(_getFocusedSearchMatchIndex);

    return HighlightedText(
      text: text,
      highlightedRegExp: searchTerm,
      style: attributeKeyStyle,
      primaryMatchStyle: theme.focusedKeySearchNodeHighlightTextStyle,
      secondaryMatchStyle: theme.keySearchHighlightTextStyle,
      focusedSearchMatchIndex: focusedSearchMatchIndex,
      highlightOnlyRegExpGroups: theme.highlightOnlyRegExpGroups,
    );
  }
}

/// A [Widget] that renders a leaf node.
class _PropertyNodeWidget extends StatelessWidget {
  final NodeViewModelState node;
  final String searchTerm;
  final Formatter? valueFormatter;
  final TextStyle style;
  final TextStyle searchHighlightStyle;
  final TextStyle focusedSearchHighlightStyle;
  final bool highlightOnlyRegExpGroups;

  const _PropertyNodeWidget({
    Key? key,
    required this.node,
    required this.searchTerm,
    required this.valueFormatter,
    required this.style,
    required this.searchHighlightStyle,
    required this.focusedSearchHighlightStyle,
    required this.highlightOnlyRegExpGroups,
  }) : super(key: key);

  /// Gets the index of the focused search match.
  int? _getFocusedSearchMatchIndex(DataExplorerStore store) {
    if (store.searchResults.isEmpty) {
      return null;
    }

    if (store.focusedSearchResult.node != node) {
      return null;
    }

    // Assert that it's the value and not the key of the node.
    if (store.focusedSearchResult.matchLocation != SearchMatchLocation.value) {
      return null;
    }

    return store.focusedSearchResult.matchIndex;
  }

  @override
  Widget build(BuildContext context) {
    final showHighlightedText = context.select<DataExplorerStore, bool>(
      (store) => store.searchResults.isNotEmpty,
    );

    final text = valueFormatter?.call(node.value) ?? node.value.toString();

    if (!showHighlightedText) {
      return Text(text, style: style);
    }

    final focusedSearchMatchIndex =
        context.select<DataExplorerStore, int?>(_getFocusedSearchMatchIndex);

    return HighlightedText(
      text: text,
      highlightedRegExp: searchTerm,
      style: style,
      primaryMatchStyle: focusedSearchHighlightStyle,
      secondaryMatchStyle: searchHighlightStyle,
      focusedSearchMatchIndex: focusedSearchMatchIndex,
      highlightOnlyRegExpGroups: highlightOnlyRegExpGroups,
    );
  }
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

/// Highlights found occurrences of [highlightedRegExp] with [highlightedStyle]
/// in [text].
class HighlightedText extends StatelessWidget {
  final String text;
  final String highlightedRegExp;
  final bool caseSensitive;
  final bool highlightOnlyRegExpGroups;

  // The default style when the text or part of it is not highlighted.
  final TextStyle style;

  // The style of the focused search match.
  final TextStyle primaryMatchStyle;

  // The style of the search match that is not focused.
  final TextStyle secondaryMatchStyle;

  // The index of the focused search match.
  final int? focusedSearchMatchIndex;

  const HighlightedText({
    Key? key,
    required this.text,
    required this.highlightedRegExp,
    this.caseSensitive = false,
    this.highlightOnlyRegExpGroups = false,
    required this.style,
    required this.primaryMatchStyle,
    required this.secondaryMatchStyle,
    required this.focusedSearchMatchIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var matchingIndexes = highlightedRegExp.isEmpty
        ? const Iterable<RegExpMatch>.empty()
        : DataExplorerStore.getIndexesOfMatches(
            highlightedRegExp,
            text,
            caseSensitive: caseSensitive,
          );
    if (matchingIndexes.isEmpty) {
      return Text(text, style: style);
    }

    // It seems that positions of matching groups are not available for now
    // (see https://github.com/dart-lang/sdk/issues/45486). We have to thus
    // take a more complex approach if we only want to highlight group contents
    // by first finding all matches, and then getting all of the group contents,
    // and finding all matches anywhere in the string that could match these
    // group contents. This will highlight potentially a lot more than just
    // the actual group matches, but is an approximation we'll have to live with
    // until the above dart:core enhancement is finished.
    if (highlightOnlyRegExpGroups) {
      final allGroups = <String>{};
      for (final m in matchingIndexes) {
        final groups = m
            .groups(List<int>.generate(m.groupCount, (index) => index + 1))
            .map((s) => s ?? '')
            .where((s) => s.isNotEmpty);
        allGroups.addAll(groups);
      }
      // for highlighting purposes, any substring that matches a known
      // group match should get highlighted. place longer groups first so
      // we always greedy match match longer expressions first.
      final sortedGroups = allGroups.toList()
        ..sort((a, b) => b.length.compareTo(a.length));
      final newRegExp = sortedGroups.map(RegExp.escape).join('|');
      matchingIndexes = DataExplorerStore.getIndexesOfMatches(
        newRegExp,
        text,
        caseSensitive: caseSensitive,
      );
    }

    final spans = <TextSpan>[];
    var start = 0;

    for (final m in matchingIndexes) {
      final index = m.start;

      if (start < index) {
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
          text: text.substring(index, m.end),
          style: index == focusedSearchMatchIndex
              ? primaryMatchStyle
              : secondaryMatchStyle,
        ),
      );
      start = m.end;
    }

    if (start != text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: style,
        ),
      );
    }

    return Text.rich(
      TextSpan(
        children: spans,
      ),
    );
  }
}
