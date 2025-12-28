import 'dart:async';
import 'package:flutter/material.dart';

import '/model/setting.dart';
import '/widgets/pincode/config.dart';
import '/service/timeslot_service.dart';
import '/widgets/timeslot_listtile.dart';
import '/widgets/pincode/pin_code_widget.dart';

class TimeSlotPage extends StatefulWidget {
  const TimeSlotPage({super.key});

  @override
  State<StatefulWidget> createState() => _TimeslotPageState();
}

class _TimeslotPageState extends State<TimeSlotPage> {
  bool _hasCorrectPin = false;
  String? _pin = Setting.timeslotPincode;
  int _clickCount = 0;
  Timer? _resetTimer;

  bool get _hasPin => _pin != null && _pin!.isNotEmpty;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  void _handlePinCompleted(String value) {
    if (_hasPin) {
      // 验证现有密码
      if (value == _pin) {
        setState(() {
          _hasCorrectPin = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('密码错误'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      // 设置新密码
      setState(() {
        _pin = value;
        Setting.save('timeslotPincode', _pin);
        _hasCorrectPin = true;
      });
    }
  }

  void _handleForgotPassword() {
    setState(() {
      _clickCount++;
    });

    _resetTimer ??= Timer(const Duration(seconds: 30), () {
      setState(() {
        _clickCount = 0;
      });
    });

    if (_clickCount == 7) {
      _resetTimer?.cancel();
      setState(() {
        _hasCorrectPin = false;
        _pin = '';
        Setting.save('timeslotPincode', '');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('密码已清空'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _hasCorrectPin ? _buildTimeslotList() : _buildPinCodeScreen();
  }

  Widget _buildPinCodeScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline_rounded, size: 50),
            const SizedBox(height: 24),
            Text(
              _hasPin ? '请输入密码' : '请设置密码',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            Builder(
              builder: (context) => PinCode(
                appContext: context,
                length: 4,
                obscureText: true,
                obscuringCharacter: '●',
                enableActiveFill: true,
                onCompleted: _handlePinCompleted,
                pinTheme: PinCodeTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 60,
                  fieldWidth: 60,
                  activeColor: Colors.grey.shade400,
                  inactiveColor: Colors.grey.shade300,
                  selectedColor: Colors.lightBlueAccent,
                  activeFillColor: Colors.white30,
                  inactiveFillColor: Colors.white10,
                  selectedFillColor: Colors.white54,
                ),
                textStyle: const TextStyle(color: Colors.black38, fontSize: 24),
              ),
            ),
            const SizedBox(height: 32),
            if (_hasPin)
              TextButton(
                onPressed: _handleForgotPassword,
                child: const Text('忘记密码?'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeslotList() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('时间管理'),
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _hasCorrectPin = false),
        ),
      ),
      body: FutureBuilder<List>(
        future: TimeSlotService.loadFromLocal(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                itemBuilder: (context, index) {
                  return TimeSlotTile(timeSlot: snapshot.data![index]);
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
