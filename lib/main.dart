import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '/utils/loggy.dart';
import '/player/agent.dart';
import '/config/route.dart';
import '/model/setting.dart';
import '/utils/dbhelper.dart';
import '/model/wallclock.dart';
import '/utils/request/cookie.dart';
import '/service/system_service.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Loggy.init();
  await RequestCookie.init();
  await DBHelper.initialize();
  MediaKit.ensureInitialized();
  await Setting.initialize();
  await WallClock.initialize();

  if (Platform.isMacOS || Platform.isWindows) {
    await WindowManager.instance.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      center: true,
      size: Size(1080, 700),
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    WindowManager.instance.waitUntilReadyToShow(windowOptions, () async {
      await WindowManager.instance.show();
      await WindowManager.instance.focus();
    });

    runApp(const DesktopApp());
  } else {
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 29) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent,
      ));
    }
    runApp(const MobileApp());
  }
  PlayerAgent.initialize();
  SystemService.activeDevice(Setting.deviceUdid);
}

class MobileApp extends StatelessWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    var lightColorScheme = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 92, 182, 123),
      brightness: Brightness.light,
    );
    final SnackBarThemeData snackBarTheme = SnackBarThemeData(
      actionTextColor: lightColorScheme.primary,
      backgroundColor: lightColorScheme.secondaryContainer,
      closeIconColor: lightColorScheme.secondary,
      contentTextStyle: TextStyle(color: lightColorScheme.secondary),
      elevation: 20,
    );
    return MaterialApp.router(
      title: '小晓视频',
      theme: ThemeData(
        colorScheme: lightColorScheme,
        snackBarTheme: snackBarTheme,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: ZoomPageTransitionsBuilder(
              allowEnterRouteSnapshotting: false,
            ),
          },
        ),
      ),
      supportedLocales: const [
        Locale('zh', 'CN'),
      ],
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (BuildContext context, Widget? child) {
        return FlutterSmartDialog(
          toastBuilder: (String msg) => CustomToast(msg: msg),
          child: MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          ),
        );
      },
      routerConfig: mobileRouter,
    );
  }
}

class DesktopApp extends StatefulWidget {
  const DesktopApp({super.key});

  @override
  State<StatefulWidget> createState() => _DesktopState();
}

class _DesktopState extends State<DesktopApp> {
  late bool isMainWindow;
  var lightColorScheme = ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 92, 182, 123),
    brightness: Brightness.light,
  );

  @override
  Widget build(BuildContext context) {
    final virtualWindowFrameBuilder = VirtualWindowFrameInit();
    final SnackBarThemeData snackBarTheme = SnackBarThemeData(
      actionTextColor: lightColorScheme.primary,
      backgroundColor: lightColorScheme.secondaryContainer,
      closeIconColor: lightColorScheme.secondary,
      contentTextStyle: TextStyle(color: lightColorScheme.secondary),
      elevation: 20,
    );

    return MaterialApp.router(
      title: '小晓视频',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: lightColorScheme,
        snackBarTheme: snackBarTheme,
      ),
      supportedLocales: const [
        Locale('zh', 'CN'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: mobileRouter,
      builder: (context, child) {
        return FlutterSmartDialog(
          toastBuilder: (String msg) => CustomToast(msg: msg),
          child: MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.0)),
            child: virtualWindowFrameBuilder(
              context,
              Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kWindowCaptionHeight),
                  child: WindowCaption(
                    brightness: Theme.of(context).brightness,
                    title: const Text('小晓视频'),
                  ),
                ),
                body: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class CustomToast extends StatelessWidget {
  const CustomToast({super.key, required this.msg});
  final String msg;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 30),
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        msg,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
