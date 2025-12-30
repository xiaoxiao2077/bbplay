import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/model/video/item.dart';

void goVideoPlay(BuildContext context, VideoItem item) {
  if (Platform.isAndroid || Platform.isIOS) {
    Map<String, dynamic> query = {'item': item};
    context.push('/video/play', extra: query);
  } else {
    Map<String, dynamic> query = {'item': item};
    context.push('/desktop/video/play', extra: query);
    return;
  }
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  String confirmText = '确定',
  String cancelText = '取消',
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: Text(cancelText,
                style: const TextStyle(color: Colors.redAccent)),
            onPressed: () {
              Navigator.of(context).pop(false); // 返回 false
            },
          ),
          TextButton(
            child:
                Text(confirmText, style: const TextStyle(color: Colors.black)),
            onPressed: () {
              Navigator.of(context).pop(true); // 返回 true
            },
          ),
        ],
      );
    },
  ).then((value) => value ?? false); // 如果返回值为 null，则默认返回 false
}
