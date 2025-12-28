import 'base_service.dart';
import '/utils/wbi_sign.dart';

class AuthorService extends BaseService {
  static Future<String> fetchSign(int mid) async {
    Map<String, dynamic> params = await WbiSign().makSign({
      'mid': mid,
      'platform': 'web',
      'web_location': 1550101,
    });
    var client = await BaseService.getApiClient();
    var resp = await BaseService.get(
      client,
      '/x/space/wbi/acc/info',
      params: params,
      parser: (json) {
        String sign;
        if (json['official']['title'].isNotEmpty &&
            json['official']['title'] != '') {
          sign = json['official']['title'];
        } else {
          sign = json["sign"];
        }
        return sign;
      },
    );
    return resp.data!;
  }
}
