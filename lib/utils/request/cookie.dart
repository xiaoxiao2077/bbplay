import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../loggy.dart';

/// 处理请求Cookie的工具类
class RequestCookie {
  // 添加缓存变量
  static CookieManager? _cookieManager;

  static Future<CookieManager> getManager() async {
    if (_cookieManager != null) {
      return _cookieManager!;
    }

    final String cookiePath = await _getCookieStoragePath();
    final PersistCookieJar cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage(cookiePath),
    );
    _cookieManager = CookieManager(cookieJar);
    return _cookieManager!;
  }

  /// 初始化Cookie管理器并加载初始Cookie
  static Future<void> init() async {
    var cookie = await loadCookie();
    if (cookie.contains('buvid')) {
      return;
    }

    try {
      Dio dio = Dio();
      final cookieManager = await getManager();
      dio.interceptors.add(cookieManager);
      await dio.get('https://api.vc.bilibili.com');
    } catch (e) {
      Loggy.e("cookie error", e);
    }

    try {
      await _buvidActivate();
    } catch (e) {
      Loggy.e("cookie error", e);
    }
  }

  static Future<String> loadCookie() async {
    final CookieManager cookieManager = await getManager();
    final List<Cookie> cookie = await cookieManager.cookieJar
        .loadForRequest(Uri.parse('https://www.bilibili.com'));

    final String cookieString = cookie
        .map((Cookie cookie) => '${cookie.name}=${cookie.value}')
        .join('; ');

    return cookieString;
  }

  /// 激活BUVID
  static Future<void> _buvidActivate() async {
    Random rand = Random();
    String randPngEnd = base64.encode(
        List<int>.generate(32, (_) => rand.nextInt(256)) +
            List<int>.filled(4, 0) +
            [73, 69, 78, 68] +
            List<int>.generate(4, (_) => rand.nextInt(256)));

    final RegExp spmPrefixExp =
        RegExp(r'<meta name="spm_prefix" content="([^"]+?)"');

    Dio dio = Dio();
    final cookieManager = await getManager();
    dio.interceptors.add(cookieManager);

    var resp = await dio.get('https://space.bilibili.com/1/dynamic');
    String spmPrefix = spmPrefixExp.firstMatch(resp.data as String)!.group(1)!;

    if (spmPrefix.isNotEmpty) {
      String payload = json.encode({
        '3064': 1,
        '39c8': '$spmPrefix.fp.risk',
        '3c43': {
          'adca': 'Linux',
          'bfe9': randPngEnd.substring(randPngEnd.length - 50),
        },
      });

      await dio.post(
          'https://api.bilibili.com/x/internal/gaia-gateway/ExClimbWuzhi',
          data: {'payload': payload},
          options: Options(contentType: 'application/json'));
    }
  }

  /// 获取Cookie存储路径
  static Future<String> _getCookieStoragePath() async {
    Directory baseDir;
    if (Platform.isAndroid && kDebugMode) {
      baseDir = (await getExternalStorageDirectory())!;
    } else {
      baseDir = await getApplicationSupportDirectory();
    }

    final String cookiePath = join(baseDir.path, 'cookies');
    final Directory dir = Directory(cookiePath);

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return cookiePath;
  }
}
