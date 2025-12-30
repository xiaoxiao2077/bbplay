import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_more_list/loading_more_list.dart';

import './loader.dart';
import '/utils/function.dart';
import '/model/video/item.dart';
import '/config/constants.dart';
import '/widgets/wallclock.dart';
import '/widgets/wallclock_wrapper.dart';
import '/widgets/vertical_listtile.dart';
import '/widgets/loading_more_indicator.dart';

class HomeVideoPage extends StatefulWidget {
  const HomeVideoPage({super.key});

  @override
  State<StatefulWidget> createState() => _HomeVideoState();
}

class _HomeVideoState extends State<HomeVideoPage> {
  late RecmdLoader dataLoader = RecmdLoader();

  @override
  Widget build(BuildContext context) {
    return WallClockWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const MobileSearchBar(),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: ClockButton(),
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
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
                    await dataLoader.refresh();
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
                          itemBuilder: (BuildContext context, VideoItem item,
                              int index) {
                            return VerticalListTile(
                              item: item,
                              onTap: (item) => goVideoPlay(context, item),
                            );
                          },
                          sourceList: dataLoader,
                          lastChildLayoutType: LastChildLayoutType.foot,
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 260,
                            childAspectRatio: aspectRatio,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 10,
                          ),
                          indicatorBuilder: (context, status) {
                            return LoadingMoreIndicator(
                              status: status,
                              loadingMoreBase: dataLoader,
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
      ),
    );
  }
}

class ClockButton extends StatelessWidget {
  const ClockButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {
        showModalBottomSheet(
          context: context,
          builder: (_) => const SizedBox(
            height: 320,
            child: ClockPanel(),
          ),
          clipBehavior: Clip.hardEdge,
          isScrollControlled: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
        ),
      },
      child: Icon(
        size: 32,
        Icons.punch_clock,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}

class MobileSearchBar extends StatelessWidget {
  const MobileSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 44,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Material(
        color: colorScheme.onSecondaryContainer.withValues(alpha: 0.05),
        child: InkWell(
          splashColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
          onTap: () => context.push('/search'),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                Icons.search_outlined,
                color: colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 10),
              Text(
                '视频搜索',
                style: TextStyle(color: colorScheme.outline),
              )
            ],
          ),
        ),
      ),
    );
  }
}
