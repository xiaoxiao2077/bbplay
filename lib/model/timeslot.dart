import 'package:flutter/material.dart';

class TimeSlot {
  late int weekday;
  late Duration duration = const Duration(minutes: 0);
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  late int updated;
  bool isEnabled = true;
  TimeSlot(int weekday);

  get dayName {
    switch (weekday) {
      case 1:
        return '周一';
      case 2:
        return '周二';
      case 3:
        return '周三';
      case 4:
        return '周四';
      case 5:
        return '周五';
      case 6:
        return '周六';
      case 7:
        return '周日';
      default:
        return '';
    }
  }

  // 转换为可读字符串
  String get displayText {
    return '${formatDuration(startTime)}-${formatDuration(endTime)} 时长${duration.inMinutes}分钟';
  }

  String formatDuration(TimeOfDay time) {
    String hour = time.hour.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  TimeSlot.fromJson(Map<String, dynamic> json) {
    weekday = json['weekday'];
    startTime = parseTimeOfDay(json['start_time']);
    endTime = parseTimeOfDay(json['end_time']);
    duration = Duration(seconds: json['duration']);
    isEnabled = json['enabled'] == 1 ? true : false;
    updated = json.containsKey('updated')
        ? json['updated'] as int
        : DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'weekday': weekday,
      'start_time': formatTimeOfDay(startTime),
      'end_time': formatTimeOfDay(endTime),
      'duration': duration.inSeconds,
      'enabled': isEnabled ? 1 : 0,
      'updated': updated,
    };
  }

  static TimeOfDay parseTimeOfDay(String timeStr) {
    List<String> parts = timeStr.split(':');
    if (parts.length == 2) {
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }

  String formatTimeOfDay(TimeOfDay time) {
    String hour = time.hour.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
