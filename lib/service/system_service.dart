import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '/model/upgrade.dart';
import '/model/setting.dart';
import './base_service.dart';

class SystemService {
  /// 检查应用更新
  static Future<ApiResponse<Upgrade>> checkUpgrade() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final platform = Platform.operatingSystem;

      final params = {
        'platform': platform,
        'app_version': packageInfo.version,
        'build_number': packageInfo.buildNumber,
      };

      var client = await BaseService.getBaseClient();
      final response = await BaseService.get(
        client,
        '/api/release/latest',
        params: params,
        parser: (data) {
          var upgrade = Upgrade.fromJson(data);
          upgrade.needUpgrade =
              _needUpgrade(packageInfo.version, upgrade.version);
          return upgrade;
        },
      );

      return response;
    } catch (e) {
      return ApiResponse.error('检查更新失败: $e');
    }
  }

  static bool _needUpgrade(localVersion, remoteVersion) {
    List<String> localVersionList = localVersion.split('.');
    List<String> remoteVersionList = remoteVersion.split('.');
    for (int i = 0; i < localVersionList.length; i++) {
      int localVersion = int.parse(localVersionList[i]);
      int remoteVersion = int.parse(remoteVersionList[i]);
      if (remoteVersion > localVersion) {
        return true;
      } else if (remoteVersion < localVersion) {
        return false;
      }
    }
    return false;
  }

  /// 注册设备(注册过也可以反复调用，会将设备id写入cookie)
  static Future<ApiResponse> activeDevice([String? udid]) async {
    try {
      final deviceUdid = udid ?? await getDeviceUdid();
      final params = {
        'udid': deviceUdid,
        'platform': Platform.operatingSystem,
        'device_name': await getDeviceName(),
        'os_version': Platform.operatingSystemVersion,
        'app_version':
            await PackageInfo.fromPlatform().then((value) => value.version),
      };
      var client = await BaseService.getBaseClient();

      final response = await BaseService.post(
        client,
        '/api/device/active',
        data: params,
      );

      if (response.success) {
        Setting.save('deviceUdid', deviceUdid);
      }

      return response;
    } catch (e) {
      return ApiResponse.error('设备注册失败: $e');
    }
  }

  /// 获取设备名称
  static Future<String> getDeviceName() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.model; // 例如: "Pixel 6 Pro"
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.name; // 例如: "John's iPhone"
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return windowsInfo.computerName; // 计算机名称
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        return macInfo.computerName; // Mac设备名称
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        return linuxInfo.name; // Linux设备名称
      }
      return "Unknown Device";
    } catch (e) {
      return "Unknown Device";
    }
  }

  /// 获取设备ID
  static Future<String> getDeviceUdid() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String? udid;

      if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        udid = macInfo.systemGUID; // macOS的设备ID
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        udid = iosInfo.identifierForVendor; // iOS的设备ID
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        udid = androidInfo.id; // Android的设备ID
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        udid = windowsInfo.deviceId;
      }

      return udid ?? const Uuid().v4();
    } catch (e) {
      return const Uuid().v4();
    }
  }
}
