import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'data_explorer_store.dart';

class JsonDataExplorer extends StatelessWidget {
  final List<NodeViewModelState> nodes;
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
          animation: nodes[index],
          builder: (BuildContext context, Widget? child) => DecoratedBox(
            decoration: BoxDecoration(
              // TODO: Configurable color.
              color: nodes[index].isHighlighted
                  ? Colors.deepPurpleAccent.withOpacity(0.2)
                  : null,
            ),
            child: child,
          ),
          child: _JsonAttribute(
            node: nodes[index],
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
    final hasSearchResult = searchTerm.isNotEmpty
        ? context.select<DataExplorerStore, bool>(
            (store) => store.searchResults.contains(node))
        : false;

    // TODO: This decorated box won't exist. It is here just to highlight
    // the search results during the SPIKE, we will have a better UI in the
    // production version.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: hasSearchResult ? Colors.lightGreen : null,
      ),
      child: MouseRegion(
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
                  Text.rich(
                    TextSpan(
                      text: node.key,
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      children: [
                        const TextSpan(
                          text: ' ',
                        ),
                        TextSpan(
                          text: _valueDisplay(),
                          style:
                              Theme.of(context).textTheme.subtitle1!.copyWith(
                                    color: _valueColor(),
                                  ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
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
