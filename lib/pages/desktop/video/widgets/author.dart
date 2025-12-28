import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/provider/playing.dart';
import '/model/video/author.dart';

class VideoAuthorView extends StatelessWidget {
  const VideoAuthorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayingState>(
      builder: (context, playingState, child) {
        final detail = playingState.detail;

        // 如果没有详情数据，显示加载状态
        if (detail == null) {
          return _buildLoadingSkeleton();
        }

        // 根据作者数量选择显示方式
        if (detail.authorList.length == 1) {
          return _buildSingleAuthor(detail.authorList[0]);
        } else {
          return _buildMultipleAuthors(detail.authorList);
        }
      },
    );
  }

  /// 构建加载状态骨架屏
  Widget _buildLoadingSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[80],
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: ListTile(
        dense: false,
        contentPadding: const EdgeInsets.all(6),
        leading: const CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey,
        ),
        title: Container(
          height: 16,
          width: 100,
          color: Colors.grey,
        ),
        subtitle: Container(
          height: 12,
          width: 150,
          color: Colors.grey,
        ),
      ),
    );
  }

  /// 构建单个作者信息
  Widget _buildSingleAuthor(VideoAuthor author) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[80],
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: ListTile(
        dense: false,
        contentPadding: const EdgeInsets.all(6),
        leading: CircleAvatar(
          backgroundImage:
              _isValidUrl(author.face) ? NetworkImage(author.face) : null,
          radius: 20,
          backgroundColor: Colors.grey[200],
          child: !_isValidUrl(author.face)
              ? const Icon(Icons.person, size: 20, color: Colors.grey)
              : null,
        ),
        title: Text(
          author.name,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFFFFB7299),
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          maxLines: 2,
          author.sign == null ? '' : author.sign!,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  /// 构建多个作者信息
  Widget _buildMultipleAuthors(List<VideoAuthor> authors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 23, 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        height: 52,
        child: ListView.builder(
          itemCount: authors.length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemBuilder: (context, index) {
            final author = authors[index];
            return Container(
              width: 90,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: _isValidUrl(author.face)
                        ? NetworkImage(author.face)
                        : null,
                    radius: 20,
                    backgroundColor: Colors.grey[200],
                    child: !_isValidUrl(author.face)
                        ? const Icon(Icons.person, size: 20, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author.name,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 检查URL是否有效
  bool _isValidUrl(String? url) {
    return url != null && url.isNotEmpty && url.startsWith('http');
  }
}
