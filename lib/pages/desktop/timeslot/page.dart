import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/widgets/pincode/config.dart';
import '/service/timeslot_service.dart';
import '/widgets/timeslot_listtile.dart';
import '/widgets/pincode/pin_code_widget.dart';

class TimeslotPage extends StatefulWidget {
  const TimeslotPage({super.key});

  @override
  State<StatefulWidget> createState() => _TimeslotPageState();
}

class _TimeslotPageState extends State<TimeslotPage> {
  late SharedPreferences prefs;
  bool hasCorrectPin = false;
  String pin = '';
  int clicked = 0;
  Timer? _timer;
  bool _isLoading = true;

  get hasPin => pin.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    _setupAutoLockTimer();
  }

  Future<void> _initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      pin = prefs.getString('pin') ?? '';
      _isLoading = false;
    });
  }

  void _setupAutoLockTimer() {
    Timer(const Duration(minutes: 3), () {
      if (mounted) {
        setState(() {
          hasCorrectPin = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingIndicator();
    }

    if (hasCorrectPin) {
      return buildTimeslotList(context);
    }

    return _buildPinVerificationScreen();
  }

  Widget _buildLoadingIndicator() {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildPinVerificationScreen() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildLockIcon(),
              const SizedBox(height: 24),
              _buildTitleText(),
              const SizedBox(height: 32),
              _buildPinCodeInput(),
              const SizedBox(height: 24),
              _buildForgotPasswordButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockIcon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        hasPin ? Icons.lock_outline : Icons.lock_open_outlined,
        size: 50,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTitleText() {
    return Text(
      hasPin ? '请输入密码' : '请设置密码',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildPinCodeInput() {
    return SizedBox(
      width: 300,
      child: PinCode(
        appContext: context,
        length: 4,
        obscureText: true,
        obscuringCharacter: '●',
        enableActiveFill: true,
        onCompleted: _handlePinCompletion,
        pinTheme: PinCodeTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(12),
          fieldHeight: 60,
          fieldWidth: 60,
          activeColor: Theme.of(context).colorScheme.primary,
          inactiveColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          selectedColor: Theme.of(context).colorScheme.primary,
          activeFillColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          inactiveFillColor: Theme.of(context).colorScheme.surface,
          selectedFillColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
        textStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _handlePinCompletion(String value) {
    if (hasPin) {
      if (value == pin) {
        setState(() {
          hasCorrectPin = true;
        });
      } else {
        _showErrorMessage('密码错误');
      }
    } else {
      setState(() {
        pin = value;
        prefs.setString('pin', pin);
        hasCorrectPin = true;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: _handleForgotPassword,
      child: Text(
        '忘记密码?',
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _handleForgotPassword() {
    clicked++;
    _timer ??= Timer(const Duration(seconds: 30), () {
      clicked = 0;
    });

    if (clicked == 7) {
      _resetPassword();
    }
  }

  void _resetPassword() {
    _timer?.cancel();
    setState(() {
      hasCorrectPin = false;
      pin = '';
      prefs.setString('pin', pin);
    });
    _showErrorMessage('密码已清空');
  }

  Widget buildTimeslotList(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          '时间管理',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => setState(() => hasCorrectPin = false),
        ),
      ),
      body: FutureBuilder(
        future: TimeSlotService.loadFromLocal(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                '加载失败: ${snapshot.error}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TimeSlotTile(timeSlot: snapshot.data![index]),
              );
            },
          );
        },
      ),
    );
  }
}
