import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/model/video/item.dart';

class Navigate {
  // 登录跳转
  static void goLogin(BuildContext context) async {
    context.push('/signin');
  }

  static void goVideoPlay(BuildContext context, VideoItem item) {
    if (Platform.isAndroid || Platform.isIOS) {
      //临时测试用
      Map<String, dynamic> query = {'item': item};
      context.push('/video/play', extra: query);
    } else {
      //@todo 判断是否已经有打开了的窗口，然后发消息
      Map<String, dynamic> query = {'item': item};
      context.push('/desktop/video/play', extra: query);
      return;
    }
  }

  // 登录跳转
}
