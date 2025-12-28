import 'dart:convert';
import 'package:dio/dio.dart';

import '/model/setting.dart';

/// 用于在用户登录时自动添加B站特定的请求头，包括：
/// 1. x-bili-mid: 用户的唯一标识符
/// 2. x-bili-aurora-eid: 用户ID的加密版本，用于追踪和识别用户
class IdentifyInterceptor extends Interceptor {
  static final Map<int, String?> _auroraCache = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (Setting.hasLogin) {
      if (Setting.mid != null && Setting.mid! > 0) {
        options.headers['x-bili-mid'] = Setting.mid.toString();
        options.headers['x-bili-aurora-eid'] = genAuroraEid(Setting.mid!);
      }
    }
    super.onRequest(options, handler);
  }

  /// 使用异或运算和Base64编码将用户ID转换为Aurora EID
  static String? genAuroraEid(int uid) {
    if (uid == 0) {
      return null;
    }

    // 首先检查缓存中是否已存在该用户ID的Aurora EID
    if (_auroraCache.containsKey(uid)) {
      return _auroraCache[uid];
    }

    String uidStr = uid.toString();
    // 使用固定字符串"ad1va46a7lza"作为密钥循环进行异或
    List<int> resultBytes = List.generate(
      uidStr.length,
      (i) => uidStr.codeUnitAt(i) ^ "ad1va46a7lza".codeUnitAt(i % 12),
    );

    // 对结果进行Base64 URL安全编码
    String auroraEid = base64Url.encode(resultBytes);
    auroraEid = auroraEid.replaceAll(RegExp(r'=*$', multiLine: true), '');
    _auroraCache[uid] = auroraEid;
    return auroraEid;
  }
}
