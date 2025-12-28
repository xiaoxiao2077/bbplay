// ignore_for_file: slash_for_doc_comments
/**
16	360P 流畅	
32	480P 清晰	
64	720P 高清	WEB 端默认值
74	720P60 高帧率	登录认证
80	1080P 高清	TV 端与 APP 端默认值 登录认证
100	智能修复	人工智能增强画质 大会员认证
112	1080P+ 高码率	大会员认证
116	1080P60 高帧率	大会员认证
120	4K 超清	需要fnval&128=128且fourk=1 大会员认证
125	HDR 真彩色	仅支持 DASH 格式 需要fnval&64=64 大会员认证
126	杜比视界	仅支持 DASH 格式 需要fnval&512=512 大会员认证
127	8K 超高清	仅支持 DASH 格式 需要fnval&1024=1024 大会员认证
 */
class VideoQuality {
  static const Map<int, String> dict = {
    16: '360P 流畅',
    32: '480P 清晰',
    64: '720P 高清',
    74: '720P 60',
    80: '1080P 高清',
    100: '智能修复',
    112: '1080P+',
    116: '1080P 60',
    120: '4K 超清',
  };

  static Map<int, String> filter(List<int> qualities) {
    Map<int, String> result = {};
    for (int quality in qualities) {
      if (dict.containsKey(quality)) {
        result[quality] = dict[quality]!;
      }
    }
    return result;
  }
}
