import 'package:flutter/material.dart';

class HotSearchList extends StatelessWidget {
  final List? keyWordList;
  final Function? onItemTap;
  const HotSearchList({this.keyWordList, this.onItemTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 100, minHeight: 20),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 5.5),
        itemCount: keyWordList!.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              keyWordList![index],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => onItemTap!(keyWordList![index]),
            trailing: const Icon(Icons.hot_tub, size: 12),
          );
        },
      ),
    );
  }
}
