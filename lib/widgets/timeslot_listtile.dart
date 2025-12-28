import 'package:flutter/material.dart';

import 'duration_picker.dart';
import '/model/timeslot.dart';
import '/model/wallclock.dart';
import '/service/timeslot_service.dart';

class TimeSlotTile extends StatefulWidget {
  final TimeSlot timeSlot;

  const TimeSlotTile({super.key, required this.timeSlot});

  @override
  State<StatefulWidget> createState() => _TimeSlotTileState();
}

class _TimeSlotTileState extends State<TimeSlotTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: Colors.white.withValues(alpha: 1),
      elevation: 0.1,
      child: ListTile(
        leading: const Icon(Icons.edit_calendar_outlined),
        title: Text(widget.timeSlot.dayName),
        subtitle: Text(widget.timeSlot.displayText),
        trailing: Transform.scale(
          scale: 0.8,
          child: Switch(
            value: widget.timeSlot.isEnabled, // 复用通知开关状态
            onChanged: (bool value) {
              setState(() {
                widget.timeSlot.isEnabled = value;
              });
              TimeSlotService.update(widget.timeSlot);
              if (widget.timeSlot.weekday == DateTime.now().weekday) {
                WallClock.setTimeslot(widget.timeSlot);
              }
            },
            activeColor: Colors.blue,
            inactiveThumbColor: Colors.grey[700],
            inactiveTrackColor: Colors.grey[300],
          ),
        ),
        onTap: () async {
          final startTime = await selectTime(widget.timeSlot.startTime, '启用时间');
          if (startTime == null) return;

          final endTime = await selectTime(widget.timeSlot.endTime, '禁用时间');
          if (endTime == null) return;

          // 验证时间顺序
          if (endTime.hour < startTime.hour ||
              (endTime.hour == startTime.hour &&
                  endTime.minute <= startTime.minute)) {
            return;
          }
          widget.timeSlot.duration =
              (await selectDuration(widget.timeSlot.duration))!;
          // 更新状态
          setState(() {
            widget.timeSlot.startTime = startTime;
            widget.timeSlot.endTime = endTime;
          });
          TimeSlotService.update(widget.timeSlot);
          if (widget.timeSlot.weekday == DateTime.now().weekday) {
            WallClock.setTimeslot(widget.timeSlot);
          }
        },
      ),
    );
  }

  // 显示时间选择器
  Future<TimeOfDay?> selectTime(TimeOfDay? initialTime, String? title) async {
    return await showTimePicker(
      context: context,
      barrierDismissible: false,
      helpText: title,
      initialEntryMode: TimePickerEntryMode.inputOnly,
      initialTime: initialTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
  }

  Future<Duration?> selectDuration(Duration? initialTime) async {
    return await showDurationPicker(
      context: context,
      initialTime: initialTime ?? const Duration(hours: 1, minutes: 30),
      baseUnit: BaseUnit.minute,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      upperBound: const Duration(hours: 12),
      lowerBound: const Duration(minutes: 15),
    );
  }
}
