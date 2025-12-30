import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';

import './loader.dart';
import '/utils/function.dart';
import '/config/constants.dart';
import '/model/video/item.dart';
import '/widgets/vertical_listtile.dart';
import '/widgets/loading_more_indicator.dart';

class SearchResultPage extends StatefulWidget {
  final String keyword;
  const SearchResultPage({required this.keyword, super.key});

  @override
  State<StatefulWidget> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  late final SearchLoader searchLoader = SearchLoader(keyword: widget.keyword);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        titleSpacing: 0,
        centerTitle: false,
        title: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              widget.keyword,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 8),
            color: Theme.of(context).colorScheme.surface,
          ),
          Expanded(
            child: Container(
              clipBehavior: Clip.hardEdge,
              margin: const EdgeInsets.only(
                  left: StyleString.safeSpace, right: StyleString.safeSpace),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(StyleString.imgRadius),
              ),
              child: RefreshIndicator(
                onRefresh: () async {
                  await searchLoader.refresh();
                },
                //这里可以计算实际的列数和一列的宽度，然后图片的高度也可以计算出来，再加上文本的宽度，
                //再计算一个宽高比，这样就能保证不溢出了
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int count = (constraints.maxWidth / 260).ceil(); //计算列数
                    double width = constraints.maxWidth / count; //计算一列的宽度
                    double imageHeight = width / (16 / 10) + 65; //计算图片的高度
                    double aspectRatio = width / imageHeight; //计算宽高比
                    return LoadingMoreList(
                      ListConfig(
                        itemBuilder:
                            (BuildContext context, VideoItem item, int index) {
                          return VerticalListTile(
                            item: item,
                            onTap: (item) => goVideoPlay(context, item),
                          );
                        },
                        sourceList: searchLoader,
                        lastChildLayoutType: LastChildLayoutType.foot,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 260,
                          childAspectRatio: aspectRatio,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 10,
                        ),
                        indicatorBuilder: (context, status) {
                          return LoadingMoreIndicator(
                            status: status,
                            loadingMoreBase: searchLoader,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
