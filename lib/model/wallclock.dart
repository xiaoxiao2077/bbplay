import 'package:flutter/material.dart';

import '/utils/dbhelper.dart';
import '/model/timeslot.dart';
import '/service/timeslot_service.dart';

class WallClock {
  static late int weekday;
  static int _elapsed = 0;
  static late String date;
  static late TimeSlot timeslot;
  static ValueNotifier statusListener =
      ValueNotifier<WallClockStatus>(WallClockStatus.available);

  static void setTimeslot(TimeSlot slot) {
    timeslot = slot;
  }

  static initialize() async {
    var now = DateTime.now();
    weekday = now.weekday;
    date = now.toIso8601String().substring(0, 10);
    timeslot = await TimeSlotService.loadToday();
    _elapsed = await loadElapsed();
  }

  static void tick(int seconds) {
    _elapsed += seconds;
    if (_elapsed % 10 == 0) {
      DBHelper.dbh.update('wall_clock', {'elapsed': _elapsed},
          where: 'date = ?', whereArgs: [date]);
      // 判断当前是否为新的一天，如果是，则新建一条记录
      DateTime now = DateTime.now();
      if (now.weekday != weekday) {
        initialize();
      }
    }
    statusListener.value = getStatus();
  }

  // 剩余时长
  static String get remainTime {
    int remainSeconds = timeslot.duration.inSeconds - _elapsed;
    if (remainSeconds <= 0) {
      return "00:00";
    }
    int remainHours = remainSeconds ~/ 3600;
    int remainMinutes = (remainSeconds % 3600) ~/ 60;
    return "${remainHours.toString().padLeft(2, '0')}:${remainMinutes.toString().padLeft(2, '0')}";
  }

  static void newRecord() {
    DBHelper.dbh.insert(
      'wall_clock',
      {'weekday': weekday, 'date': date, 'elapsed': 0},
    );
  }

  // 从本地数据库加载已用时长
  static Future loadElapsed() async {
    List<Map<String, dynamic>> result = await DBHelper.dbh
        .query('wall_clock', where: 'date = ?', whereArgs: [date], limit: 1);
    if (result.isEmpty) {
      newRecord();
      return 0;
    } else {
      return result.first['elapsed'];
    }
  }

  static WallClockStatus getStatus() {
    if (timeslot.isEnabled == false) {
      return WallClockStatus.disabled;
    } else if (_elapsed >= timeslot.duration.inSeconds) {
      return WallClockStatus.runout;
    }
    TimeOfDay current = TimeOfDay.fromDateTime(DateTime.now());
    if (current.isAfter(timeslot.endTime)) {
      return WallClockStatus.expired;
    }

    if (current.isBefore(timeslot.startTime)) {
      return WallClockStatus.unavailable;
    }
    return WallClockStatus.available;
  }

  // 时间段的字符串表示
  static String get timeRange {
    return "${timeslot.startTime.hour.toString().padLeft(2, '0')}:${timeslot.startTime.minute.toString().padLeft(2, '0')} "
        "-"
        "${timeslot.endTime.hour.toString().padLeft(2, '0')}:${timeslot.endTime.minute.toString().padLeft(2, '0')}";
  }

  // 时长的字符串表示
  static String get duration {
    return "${timeslot.duration.inMinutes}分钟";
  }

  // 已用时长的字符串表示
  static String get elapsedTime {
    int minutes = _elapsed ~/ 60;
    return "$minutes分钟";
  }
}

enum WallClockStatus {
  available, // 可用
  unavailable, // 不可用（未到开始时间）
  expired, // 已过期（超过结束时间）
  disabled, // 已禁用
  runout, // 时长已用完
}
