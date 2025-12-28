import '/model/timeslot.dart';
import '/utils/dbhelper.dart';
import '/service/base_service.dart';

class TimeSlotService extends BaseService {
  static Future<TimeSlot> loadToday() async {
    int weekday = DateTime.now().weekday;
    var result = await DBHelper.dbh
        .query('timeslot', where: 'weekday = ?', whereArgs: [weekday]);
    Map<String, dynamic> json = result.first;
    TimeSlot timeslot = TimeSlot.fromJson(json);
    return timeslot;
  }

  static Future<List<TimeSlot>> loadFromLocal() async {
    var result = await DBHelper.dbh.query('timeslot', limit: 7);
    return result.map((item) {
      return TimeSlot.fromJson(item);
    }).toList();
  }

  static void update(TimeSlot timeslot) {
    int weekday = timeslot.weekday;
    timeslot.updated = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    DBHelper.dbh.update('timeslot', timeslot.toJson(),
        where: 'weekday = ? ', whereArgs: [weekday]);
    remoteSubmit(timeslot);
  }

  static Future remoteSubmit(TimeSlot item) async {
    var client = await BaseService.getBaseClient();
    await client.post('/api/timeslot/submit', item.toJson());
  }

  //保存到数据库
  static Future syncLoadFromServer() async {
    var client = await BaseService.getBaseClient();
    Map resp = await client.get('/api/timeslot/load', null);
    if (resp['success']) {
      resp['data'].forEach((item) {
        var timeslot = TimeSlot.fromJson(item);
        int weekday = timeslot.weekday;
        DBHelper.dbh.update(
          'timeslot',
          timeslot.toJson(),
          where: 'weekday = ? AND updated<?',
          whereArgs: [weekday, timeslot.updated],
        );
      });
    }
  }
}
