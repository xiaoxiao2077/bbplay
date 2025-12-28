import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '/player/agent.dart';
import '/model/wallclock.dart';

class WallClockWrapper extends StatefulWidget {
  final Widget child;
  const WallClockWrapper({super.key, required this.child});

  @override
  State<StatefulWidget> createState() => _WallClockState();
}

class _WallClockState extends State<WallClockWrapper> {
  @override
  void initState() {
    super.initState();
    WallClock.statusListener.addListener(handleStatusChange);
    handleStatusChange();
  }

  @override
  void dispose() {
    super.dispose();
    WallClock.statusListener.removeListener(handleStatusChange);
  }

  // 处理状态变化的方法
  void handleStatusChange() {
    final status = WallClock.statusListener.value;
    if (status == WallClockStatus.runout) {
      _showStatusDialog(
        title: '今日播放时长已用完',
        message: '今日可观看视频${WallClock.duration} 已观看${WallClock.elapsedTime}',
        icon: Icons.timer_off,
        color: Colors.orange,
      );
      PlayerAgent.pause();
    } else if (status == WallClockStatus.expired) {
      _showStatusDialog(
        title: '已超过可播放时段',
        message: '今日可播放时段${WallClock.timeRange}',
        icon: Icons.access_time_outlined,
        color: Colors.red,
      );
      PlayerAgent.pause();
    } else if (status == WallClockStatus.disabled) {
      _showStatusDialog(
        title: '今日播放已禁用',
        message: '请选择其他时间段播放',
        icon: Icons.lock_outline,
        color: Colors.grey,
      );
      PlayerAgent.pause();
    } else if (status == WallClockStatus.unavailable) {
      _showStatusDialog(
        title: '还未到观看时间',
        message: '今日可播放时段${WallClock.timeRange}',
        icon: Icons.access_time,
        color: Colors.blue,
      );
      PlayerAgent.pause();
    }
  }

  // 显示带图标的对话框
  void _showStatusDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    SmartDialog.show(
      animationType: SmartAnimationType.fade,
      builder: (context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                SmartDialog.dismiss();
                WallClock.statusListener.value = WallClockStatus.available;
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
