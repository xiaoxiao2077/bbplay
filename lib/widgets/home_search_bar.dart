import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'home_search_filter.dart';

class HomeSearchBar<T> extends StatefulWidget implements PreferredSizeWidget {
  /// Returns the current search value
  /// When search is closed, this method returns an empty value to clear the current search
  final Function(String) onSearch;

  /// Extra custom actions that can be displayed inside AppBar
  final List<Widget> actions;

  /// Can be used to change AppBar background color
  final Color? backgroundColor;

  /// Can be used to change AppBar foreground color
  final Color? foregroundColor;

  /// Can be used to change AppBar height
  final double appBarHeight;

  /// Can be used to determine if the suggestions overlay will be opened when clicking search
  final bool openOverlayOnSearch;

  /// Can be used to set the search input background color
  final Color? searchBackgroundColor;

  /// Can be used to set search textField cursor color
  final Color? searchCursorColor;

  /// Can be used to set search textField hint text
  final String searchHintText;

  /// Can be used to set search textField hint style
  final TextStyle? searchHintStyle;

  /// Can be used to set search textField text style
  final TextStyle searchTextStyle;

  /// Can be used to set search textField keyboard type
  final TextInputType searchTextKeyboardType;

  /// Can be used to set custom icon theme for the search textField back button
  final IconThemeData? searchBackIconTheme;

  /// Can be used to set custom icon theme for the search clear textField button
  final IconThemeData? searchClearIconTheme;

  /// Can be used to set SystemUiOverlayStyle to the AppBar
  final SystemUiOverlayStyle? systemOverlayStyle;

  /// Can be used to create a suggestions list
  final List<T>? suggestions;

  /// Can be used to set async suggestions list
  final Future<List<T>> Function(String value)? asyncSuggestions;

  /// Can be used to change suggestion list elevation
  final double suggestionsElevation;

  /// A function that can be used to create a widget to display a custom suggestions loader
  final Widget Function()? suggestionLoaderBuilder;

  /// Can be used to change the suggestions text style
  final TextStyle suggestionTextStyle;

  /// Can be used to change suggestions list background color
  final Color? suggestionBackgroundColor;

  /// Can be used to create custom suggestion item widget
  final Widget Function(T data)? suggestionBuilder;

  /// Instead of using the default suggestion tap action that fills the textField, you can set your own custom action for it
  final Function(T data)? onSuggestionTap;

  /// Converts a given suggested item to a corresponding string
  final String Function(T data)? suggestionToString;

  /// Can be used to set the debounce time for async data fetch
  final Duration debounceDuration;

  /// Can be uses to allow user to cancel suggestions with escape or back button.
  final bool cancelableSuggestions;

  const HomeSearchBar({
    super.key,
    required this.onSearch,
    this.suggestionBuilder,
    this.actions = const [],
    this.searchHintStyle,
    this.searchTextStyle = const TextStyle(),
    this.systemOverlayStyle,
    this.suggestions,
    this.onSuggestionTap,
    this.suggestionToString,
    this.searchBackIconTheme,
    this.searchClearIconTheme,
    this.asyncSuggestions,
    this.searchCursorColor,
    this.searchHintText = '',
    this.searchBackgroundColor,
    this.suggestionLoaderBuilder,
    this.suggestionsElevation = 4,
    this.backgroundColor,
    this.foregroundColor,
    this.appBarHeight = 56,
    this.openOverlayOnSearch = false,
    this.suggestionTextStyle = const TextStyle(),
    this.suggestionBackgroundColor,
    this.debounceDuration = const Duration(milliseconds: 400),
    this.searchTextKeyboardType = TextInputType.text,
    this.cancelableSuggestions = true,
  });

  @override
  State<HomeSearchBar<T>> createState() => _SearchBarState<T>();

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}

class _SearchBarState<T> extends State<HomeSearchBar<T>>
    with TickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  bool _hasOpenedOverlay = false;
  bool _isLoading = false;
  OverlayEntry? _overlayEntry;
  List<T> _suggestions = [];
  Timer? _debounce;
  String _previousAsyncSearchText = '';
  final FocusNode _focusNode = FocusNode();

  final TextEditingController _searchController = TextEditingController();
  bool hasFocus = false;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() async {
      if (_focusNode.hasFocus) {
        if (widget.suggestions != null) {
          openOverlay();
          updateSyncSuggestions(_searchController.text);
        } else if (widget.asyncSuggestions != null) {
          openOverlay();
          updateAsyncSuggestions(_searchController.text);
        }
      }
    });
    _focusNode.addListener(() {
      setState(() {
        hasFocus = _focusNode.hasFocus;
      });
    });
  }

  Widget? _suggestionLoaderBuilder() {
    Widget? child;
    if (widget.suggestionLoaderBuilder != null) {
      child = widget.suggestionLoaderBuilder!();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      child = const CupertinoActivityIndicator();
    } else {
      child = const CircularProgressIndicator();
    }

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: child,
    );
  }

  void openOverlay() {
    if (_overlayEntry == null &&
        (widget.suggestions != null || widget.asyncSuggestions != null)) {
      RenderBox renderBox = context.findRenderObject() as RenderBox;
      Size size = renderBox.size;
      Offset offset = renderBox.localToGlobal(Offset.zero);

      _overlayEntry ??= OverlayEntry(
        builder: (context) => Positioned(
          left: offset.dx,
          top: offset.dy + size.height,
          width: size.width - 50,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0.0, size.height),
            child: _buildSuggestionsOverlay(size),
          ),
        ),
      );
    }
    if (!_hasOpenedOverlay &&
        (widget.suggestions != null || widget.asyncSuggestions != null)) {
      Overlay.of(context).insert(_overlayEntry!);
      setState(() => _hasOpenedOverlay = true);
    }
  }

  /// 构建美化后的建议弹出层
  Widget _buildSuggestionsOverlay(Size size) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.suggestionBackgroundColor ??
            Theme.of(context).cardColor.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FilterableList<T>(
          loading: _isLoading,
          loader: _suggestionLoaderBuilder(),
          items: _suggestions,
          suggestionBuilder: widget.suggestionBuilder,
          elevation: widget.suggestionsElevation,
          suggestionTextStyle: widget.suggestionTextStyle,
          suggestionBackgroundColor: widget.suggestionBackgroundColor,
          suggestionToString: suggestionToString,
          onItemTapped: (value) {
            _searchController.value = TextEditingValue(
              text: suggestionToString(value),
              selection: TextSelection.collapsed(
                  offset: suggestionToString(value).length),
            );
            if (widget.onSuggestionTap != null) {
              widget.onSuggestionTap!(value);
            }
            widget.onSearch(suggestionToString(value));
            closeOverlay();
          },
        ),
      ),
    );
  }

  void closeOverlay() {
    if (_hasOpenedOverlay) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      setState(() => _hasOpenedOverlay = false);
    }
  }

  void updateSyncSuggestions(String input) {
    _suggestions = widget.suggestions!.where((element) {
      return suggestionToString(element)
          .toLowerCase()
          .contains(input.toLowerCase());
    }).toList();
    rebuildOverlay();
  }

  Future<void> updateAsyncSuggestions(String input) async {
    if (_previousAsyncSearchText != input ||
        _previousAsyncSearchText.isEmpty ||
        input.isEmpty) {
      if (_debounce != null && _debounce!.isActive) {
        _debounce!.cancel();
      }
      setState(() => _isLoading = true);
      _debounce = Timer(widget.debounceDuration, () async {
        _suggestions = await widget.asyncSuggestions!(input);
        setState(() {
          _isLoading = false;
          _previousAsyncSearchText = input;
        });
        rebuildOverlay();
      });
    }
  }

  void rebuildOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  String Function(T) get suggestionToString =>
      widget.suggestionToString ?? (s) => s.toString();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppBarThemeData appBarTheme = AppBarTheme.of(context);
    final ScaffoldState? scaffold = Scaffold.maybeOf(context);

    Color? backgroundColor = widget.backgroundColor ??
        appBarTheme.backgroundColor ??
        theme.primaryColor;

    Color? searchBackgroundColor = widget.searchBackgroundColor ??
        scaffold!.widget.backgroundColor ??
        theme.inputDecorationTheme.fillColor ??
        theme.scaffoldBackgroundColor;

    TextStyle searchHintStyle = widget.searchHintStyle ??
        theme.inputDecorationTheme.hintStyle ??
        const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic);

    SystemUiOverlayStyle systemOverlayStyle = widget.systemOverlayStyle ??
        appBarTheme.systemOverlayStyle ??
        (theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark);

    return PopScope(
      onPopInvokedWithResult: (_, __) => closeOverlay(),
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            closeOverlay();
          }
        },
        child: CompositedTransformTarget(
          link: _layerLink,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: systemOverlayStyle,
            child: Material(
              color: backgroundColor,
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Material(
                      color: backgroundColor,
                      child: Container(
                        height: widget.appBarHeight,
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                            top: 10, left: 15, right: 3, bottom: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextField(
                                onSubmitted: (value) {
                                  widget.onSearch(_searchController.text);
                                  _focusNode.unfocus();
                                  closeOverlay();
                                },
                                maxLines: 1,
                                controller: _searchController,
                                textInputAction: TextInputAction.search,
                                focusNode: _focusNode,
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: widget.searchTextKeyboardType,
                                cursorWidth: 1,
                                cursorHeight: 14,
                                decoration: InputDecoration(
                                  fillColor: searchBackgroundColor,
                                  filled: true,
                                  hintText: widget.searchHintText,
                                  hintMaxLines: 1,
                                  hintStyle: searchHintStyle,
                                  prefixIcon: IconButton(
                                    icon: const Icon(Icons.search),
                                    iconSize: 20,
                                    onPressed: () {
                                      _focusNode.requestFocus();
                                      openOverlay();
                                    },
                                  ),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(
                                        color: Colors.blue, width: 0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  suffixIcon: hasFocus
                                      ? IconButton(
                                          icon: const Icon(Icons.close_rounded),
                                          iconSize: 20,
                                          onPressed: () {
                                            _searchController.clear();
                                            _focusNode.unfocus();
                                            closeOverlay();
                                          },
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            ...List.generate(widget.actions.length, (index) {
                              return widget.actions[index];
                            })
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
