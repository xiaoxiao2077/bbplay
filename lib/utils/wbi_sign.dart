// Wbi签名 用于生成 REST API 请求中的 w_rid 和 wts 字段
// https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/misc/sign/wbi.md
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '/utils/request/client.dart';

class WbiSign {
  final List<int> mixinKeyEncTab = <int>[
    46,
    47,
    18,
    2,
    53,
    8,
    23,
    32,
    15,
    50,
    10,
    31,
    58,
    3,
    45,
    35,
    27,
    43,
    5,
    49,
    33,
    9,
    42,
    19,
    29,
    28,
    14,
    39,
    12,
    38,
    41,
    13,
    37,
    48,
    7,
    16,
    24,
    55,
    40,
    61,
    26,
    17,
    0,
    1,
    60,
    51,
    30,
    4,
    22,
    25,
    54,
    21,
    56,
    59,
    6,
    63,
    57,
    62,
    11,
    36,
    20,
    34,
    44,
    52
  ];
  static Map<String, dynamic>? _wbiKeys;
  static DateTime? _wbiKeysTime;
  // 对 imgKey 和 subKey 进行字符顺序打乱编码
  String getMixinKey(String orig) {
    String temp = '';
    for (int i = 0; i < mixinKeyEncTab.length; i++) {
      temp += orig.split('')[mixinKeyEncTab[i]];
    }
    return temp.substring(0, 32);
  }

  // 为请求参数进行 wbi 签名
  Map<String, dynamic> encWbi(
      Map<String, dynamic> params, String imgKey, String subKey) {
    final String mixinKey = getMixinKey(imgKey + subKey);
    final DateTime now = DateTime.now();
    final int currTime = (now.millisecondsSinceEpoch / 1000).round();
    final RegExp chrFilter = RegExp(r"[!\'\(\)*]");
    final List<String> query = <String>[];
    final Map<String, dynamic> newParams = Map.from(params)
      ..addAll({"wts": currTime}); // 添加 wts 字段
    // 按照 key 重排参数
    final List<String> keys = newParams.keys.toList()..sort();
    for (String i in keys) {
      query.add(
          '${Uri.encodeComponent(i)}=${Uri.encodeComponent(newParams[i].toString().replaceAll(chrFilter, ''))}');
    }
    final String queryStr = query.join('&');
    final String wbiSign =
        md5.convert(utf8.encode(queryStr + mixinKey)).toString(); // 计算 w_rid
    return {'wts': currTime.toString(), 'w_rid': wbiSign};
  }

  // 获取 wts 和 w_rid
  static Map<String, String> getWbiParams(String wbiSign) {
    final int currTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return {'wts': currTime.toString(), 'w_rid': wbiSign};
  }

  // 获取最新的 img_key 和 sub_key 可以从缓存中获取
  static Future<Map<String, dynamic>> getWbiKeys() async {
    // 检查缓存是否过期 (24小时有效期)
    if (_wbiKeys != null && _wbiKeysTime != null) {
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(_wbiKeysTime!);
      if (difference.inHours < 24) {
        return _wbiKeys!;
      }
    }
    var client =
        await DioClient.getInstance(baseUrl: 'https://api.bilibili.com');
    // 缓存过期或没有缓存，重新获取
    var resp = await client.get('/x/web-interface/nav', null, rawoutput: false);

    final String imgUrl = resp['data']['wbi_img']['img_url'];
    final String subUrl = resp['data']['wbi_img']['sub_url'];
    final Map<String, dynamic> wbiKeys = {
      'imgKey': imgUrl
          .substring(imgUrl.lastIndexOf('/') + 1, imgUrl.length)
          .split('.')[0],
      'subKey': subUrl
          .substring(subUrl.lastIndexOf('/') + 1, subUrl.length)
          .split('.')[0]
    };

    // 更新静态属性
    _wbiKeys = wbiKeys;
    _wbiKeysTime = DateTime.now();
    return wbiKeys;
  }

  Future<Map<String, dynamic>> makSign(Map<String, dynamic> params) async {
    // params 为需要加密的请求参数
    final Map<String, dynamic> wbiKeys = await getWbiKeys();
    final Map<String, dynamic> query = params
      ..addAll(encWbi(params, wbiKeys['imgKey'], wbiKeys['subKey']));
    return query;
  }
}
