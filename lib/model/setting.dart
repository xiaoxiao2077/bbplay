import 'package:shared_preferences/shared_preferences.dart';

class Setting {
  static bool hasLogin = false;
  static int? mid;
  static String? uname;
  static String? face;
  static String? deviceUdid;
  static String? timeslotPincode;

  static late SharedPreferences prefs;

  static initialize() async {
    prefs = await SharedPreferences.getInstance();
    hasLogin = prefs.getBool('hasLogin') ?? false;
    mid = prefs.getInt('mid') ?? 0;
    uname = prefs.getString('name') ?? '';
    face = prefs.getString('face') ?? '';
    deviceUdid = prefs.getString('deviceUdid');
    timeslotPincode = prefs.getString('timeslotPincode');
  }

  static save(key, dynamic value) {
    if (key == 'hasLogin') {
      hasLogin = value;
      prefs.setBool('hasLogin', hasLogin);
    } else if (key == 'mid') {
      mid = value;
      prefs.setInt('mid', mid!);
    } else if (key == 'uname') {
      uname = value;
      prefs.setString('uname', uname!);
    } else if (key == 'face') {
      face = value;
      prefs.setString('face', face!);
    } else if (key == 'deviceUdid') {
      deviceUdid = value;
      prefs.setString('deviceUdid', deviceUdid!);
    } else if (key == 'timeslotPincode') {
      timeslotPincode = value;
      prefs.setString('timeslotPincode', timeslotPincode!);
    }
  }
}
