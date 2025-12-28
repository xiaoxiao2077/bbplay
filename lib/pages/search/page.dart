import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/widgets/search/text.dart';
import '/service/search_service.dart';
import '/widgets/search/hotlist.dart';

class SearchVideoPage extends StatefulWidget {
  const SearchVideoPage({super.key});

  @override
  State<StatefulWidget> createState() => _SearchVideoPageState();
}

class _SearchVideoPageState extends State<SearchVideoPage> {
  final FocusNode _focusNode = FocusNode();
  final Debounce _debouncer = Debounce(const Duration(milliseconds: 300));
  final TextEditingController _searchController = TextEditingController();

  List<String> _searchHistory = [];
  List<String> _searchSuggestions = [];
  List<String> _hotKeywords = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchInputChange);
    _loadSearchHistory();
    _loadHotSearch();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchInputChange);
    _searchController.dispose();
    _focusNode.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  // 加载搜索历史
  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('search_history') ?? [];
      setState(() {
        _searchHistory = history;
      });
    } catch (e) {
      debugPrint('Failed to load search history: $e');
    }
  }

  // 保存搜索历史
  Future<void> _saveSearchHistory(String query) async {
    if (query.isEmpty) return;

    try {
      // 移除重复项并添加到最前面
      final updatedHistory = List<String>.from(_searchHistory);
      updatedHistory.remove(query);
      updatedHistory.insert(0, query);

      // 限制历史记录数量
      if (updatedHistory.length > 10) {
        updatedHistory.removeRange(10, updatedHistory.length);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('search_history', updatedHistory);

      setState(() {
        _searchHistory = updatedHistory;
      });
    } catch (e) {
      debugPrint('Failed to save search history: $e');
    }
  }

  // 加载热门搜索
  Future<void> _loadHotSearch() async {
    try {
      final response = await SearchService.hotSearchList();
      if (response.success && response.data != null) {
        setState(() {
          _hotKeywords = response.data!;
        });
      }
    } catch (e) {
      debugPrint('Failed to load hot search: $e');
    }
  }

  // 搜索文本变化时的回调
  void _onSearchInputChange() {
    final query = _searchController.text.trim();
    setState(() {
      _showSuggestions = query.isNotEmpty;
    });

    if (query.isNotEmpty) {
      // 使用防抖避免频繁请求
      _debouncer.run(() => _fetchSearchSuggestions(query));
    } else {
      setState(() {
        _searchSuggestions = [];
      });
    }
  }

  // 获取搜索建议
  Future<void> _fetchSearchSuggestions(String term) async {
    final response = await SearchService.searchSuggest(term);
    if (response.success && response.data != null) {
      setState(() {
        _searchSuggestions = response.data!;
      });
    }
  }

  // 执行搜索
  void _performSearch() {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;

    _saveSearchHistory(keyword);
    _hideKeyboard();

    final query = {'keyword': keyword};
    context.push('/search/result', extra: query);
  }

  // 清除搜索历史
  Future<void> _clearSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('search_history');
      setState(() {
        _searchHistory.clear();
      });
    } catch (e) {
      debugPrint('Failed to clear search history: $e');
    }
  }

  // 隐藏键盘
  void _hideKeyboard() {
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            onPressed: _performSearch,
            icon: const Icon(CupertinoIcons.search, size: 22),
          ),
          const SizedBox(width: 10)
        ],
        title: TextField(
          autofocus: true,
          focusNode: _focusNode,
          controller: _searchController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: '搜索视频',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                size: 22,
                color: Theme.of(context).colorScheme.outline,
              ),
              onPressed: () {
                _searchController.clear();
              },
            ),
          ),
          onSubmitted: (_) => _performSearch(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 2),
            _buildSuggestPanel(),
            _buildHotListPanel(),
            _buildHistoryPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildHotListPanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '大家都在搜',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 34,
                  child: TextButton.icon(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(const EdgeInsets.only(
                          left: 10, top: 6, bottom: 6, right: 10)),
                    ),
                    onPressed: _loadHotSearch,
                    icon: const Icon(Icons.refresh_outlined, size: 18),
                    label: const Text('刷新'),
                  ),
                ),
              ],
            ),
          ),
          HotSearchList(
            onItemTap: (value) {
              _searchController.text = value;
              _performSearch();
            },
            keyWordList: _hotKeywords,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPanel() {
    if (_searchHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 25, 6, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 0, 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '搜索历史',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                TextButton(
                  onPressed: _clearSearchHistory,
                  child: const Text('清空'),
                )
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            direction: Axis.horizontal,
            textDirection: TextDirection.ltr,
            children: [
              for (var item in _searchHistory)
                SearchText(
                  searchText: item,
                  onSelect: (value) {
                    _searchController.text = value;
                    _performSearch();
                  },
                )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestPanel() {
    if (!_showSuggestions || _searchSuggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 300, minHeight: 10),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _searchSuggestions.length,
        itemExtent: 30,
        itemBuilder: (context, index) {
          final suggestion = _searchSuggestions[index];
          return ListTile(
            title: Text(suggestion),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            dense: true,
            onTap: () {
              _searchController.text = suggestion;
              _performSearch();
            },
          );
        },
      ),
    );
  }
}

// 防抖工具类
class Debounce {
  final Duration delay;
  Timer? _timer;

  Debounce(this.delay);

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
