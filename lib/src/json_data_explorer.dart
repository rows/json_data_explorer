import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'data_explorer_store.dart';

class JsonDataExplorer extends StatelessWidget {
  final Iterable<NodeViewModelState> nodes;
  final ItemScrollController? itemScrollController;
  final ItemPositionsListener? itemPositionsListener;

  const JsonDataExplorer({
    Key? key,
    required this.nodes,
    this.itemScrollController,
    this.itemPositionsListener,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ScrollablePositionedList.builder(
        itemCount: nodes.length,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        itemBuilder: (context, index) => AnimatedBuilder(
          animation: nodes.elementAt(index),
          builder: (context, child) => DecoratedBox(
            decoration: BoxDecoration(
              // TODO: Configurable color.
              color: nodes.elementAt(index).isHighlighted
                  ? Colors.deepPurpleAccent.withOpacity(0.2)
                  : null,
            ),
            child: child,
          ),
          child: _JsonAttribute(
            node: nodes.elementAt(index),
          ),
        ),
      );
}

class _JsonAttribute extends StatelessWidget {
  final NodeViewModelState node;
  final double indentationPadding;

  const _JsonAttribute({
    Key? key,
    required this.node,
    this.indentationPadding = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = node.isRoot && node.treeDepth > 1
        ? (node.treeDepth - 1) * indentationPadding
        : node.treeDepth * indentationPadding;

    final searchTerm =
        context.select<DataExplorerStore, String>((store) => store.searchTerm);
    final isSearchFocused = context.select<DataExplorerStore, bool>((store) =>
        store.searchResults.isNotEmpty
            ? store.searchResults.elementAt(store.searchNodeFocusIndex) == node
            : false);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => node.highlight(true),
      onExit: (event) => node.highlight(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(context),
        child: AnimatedBuilder(
          animation: node,
          builder: (BuildContext context, Widget? child) => Padding(
            padding: EdgeInsets.only(left: padding),
            child: Row(
              children: [
                if (node.isRoot)
                  SizedBox(
                    width: indentationPadding,
                    // TODO: Configurable icons.
                    child: node.isCollapsed
                        ? const Icon(Icons.arrow_right)
                        : const Icon(Icons.arrow_drop_down),
                  ),
                // TODO: configurable theme.
                _HighlightedText(
                  text: '${node.key}: ',
                  highlightedText: searchTerm,
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  highlightedStyle:
                      Theme.of(context).textTheme.subtitle1!.copyWith(
                            fontWeight: FontWeight.bold,
                            backgroundColor: isSearchFocused
                                ? Colors.deepPurpleAccent
                                : Colors.grey,
                          ),
                ),
                _HighlightedText(
                  text: _valueDisplay(),
                  highlightedText: searchTerm,
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        color: _valueColor(),
                      ),
                  highlightedStyle:
                      Theme.of(context).textTheme.subtitle1!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _valueColor(),
                            backgroundColor: isSearchFocused
                                ? Colors.deepPurpleAccent
                                : Colors.grey,
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _onTap(BuildContext context) async {
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

  String _valueDisplay() {
    if (node.isClass) {
      return '{${(node.childrenCount)}}';
    } else if (node.isArray) {
      return '[${node.childrenCount}]';
    }
    return node.value.toString();
  }

  Color _valueColor() {
    if (node.isRoot) {
      return Colors.grey;
    }
    return Colors.redAccent;
  }
}

/// Highlights found occurrences of [highlightedText] with [highlightedStyle]
/// in [text].
class _HighlightedText extends StatelessWidget {
  final String text;
  final String highlightedText;
  final TextStyle style;
  final TextStyle highlightedStyle;
  final TextAlign textAlign;

  const _HighlightedText({
    Key? key,
    required this.text,
    required this.highlightedText,
    required this.style,
    required this.highlightedStyle,
    this.textAlign = TextAlign.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lowerCaseText = text.toLowerCase();
    final lowerCaseQuery = highlightedText.toLowerCase();
    if (highlightedText.isEmpty || !lowerCaseText.contains(lowerCaseQuery)) {
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
      textAlign: textAlign,
    );
  }
}
