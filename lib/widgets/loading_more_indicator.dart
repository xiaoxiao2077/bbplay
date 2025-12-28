import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';

class LoadingMoreIndicator extends StatelessWidget {
  final LoadingMoreBase<dynamic>? loadingMoreBase;
  final IndicatorStatus status;

  const LoadingMoreIndicator({
    super.key,
    required this.status,
    this.loadingMoreBase,
  });

  @override
  Widget build(BuildContext context) {
    // 构建加载指示器
    if (status == IndicatorStatus.none) {
      return Container();
    }

    Widget widget;
    switch (status) {
      case IndicatorStatus.loadingMoreBusying:
        widget = const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.0),
            ),
            SizedBox(width: 10),
            Text('加载中...'),
          ],
        );
        break;
      case IndicatorStatus.fullScreenBusying:
        widget = const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(),
            ),
            SizedBox(width: 10),
            Text('加载中...'),
          ],
        );
        break;
      case IndicatorStatus.error:
        widget = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('加载失败，点击重试'),
            TextButton(
              onPressed: () {
                loadingMoreBase!.errorRefresh();
              },
              child: const Text('重试'),
            ),
          ],
        );
        break;
      case IndicatorStatus.fullScreenError:
        widget = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('加载失败，点击重试'),
            TextButton(
              onPressed: () {
                loadingMoreBase!.errorRefresh();
              },
              child: const Text('重试'),
            ),
          ],
        );
        break;
      case IndicatorStatus.noMoreLoad:
        widget = const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('没有更多数据了'),
          ],
        );
        break;
      case IndicatorStatus.empty:
        widget = const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('暂无数据'),
          ],
        );
        break;
      default:
        widget = Container();
        break;
    }
    return Container(
      padding: const EdgeInsets.all(16),
      child: widget,
    );
  }
}
