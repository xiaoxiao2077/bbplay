import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

/// Handles request signing and encryption using HMAC-SHA256.
class RequestSigner {
  static const String accessKey = 'xiaoxiaov';
  static const String secretKey = 'sdvb23fhd332kvds346k';

  static String _generateTimestamp() {
    return (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
  }

  /// Builds the sign string based on method, path, params, headers and body.
  static String _buildSignString({
    required String method,
    required String path,
    required Map<String, String> params,
  }) {
    final uri = Uri.parse(path);
    final parts = <String>[method.toUpperCase(), uri.path];
    final sortedKeys = params.keys.toList()..sort();
    final queryParts = <String>[];
    for (final key in sortedKeys) {
      queryParts.add(
          '${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(params[key]!)}');
    }
    parts.add(queryParts.join('&'));
    return parts.join('\n');
  }

  /// Calculates HMAC-SHA256 signature.
  static String _calculateSignature(String signString) {
    final key = utf8.encode(secretKey);
    final bytes = utf8.encode(signString);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString();
  }

  /// Signs the request and returns signature-related headers.
  static Map<String, String> sign({
    required String method,
    required String path,
  }) {
    final timestamp = _generateTimestamp();

    final signParams = <String, String>{
      'access_key': accessKey,
      'timestamp': timestamp,
    };

    final signString = _buildSignString(
      method: method,
      path: path,
      params: signParams,
    );
    final signature = _calculateSignature(signString);
    return {
      'x-access-key': accessKey,
      'x-timestamp': timestamp,
      's-signature': signature,
    };
  }
}

/// Dio Interceptor for adding signed parameters to requests.
class RequestInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final method = options.method;
    final path = options.path;

    // Convert queryParameters to Map<String, String>
    final params = <String, String>{};
    options.queryParameters.forEach((key, value) {
      if (value is String || value is num || value is bool) {
        params[key] = value.toString();
      }
    });

    // Sign the request
    final signatureHeaders = RequestSigner.sign(method: method, path: path);
    options.headers.addAll(signatureHeaders);
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    String url = err.requestOptions.uri.toString();
    final excludedPatterns = RegExp(r'heartbeat|seg\.so|online/total');
    if (!excludedPatterns.hasMatch(url)) {
      SmartDialog.showToast(await networkError(err),
          displayType: SmartToastType.onlyRefresh,
          displayTime: const Duration(seconds: 1));
    }
    super.onError(err, handler);
  }

  /// Maps DioException types to user-friendly messages.
  static Future<String> networkError(DioException error) async {
    switch (error.type) {
      case DioExceptionType.badCertificate:
        return '证书有误！';
      case DioExceptionType.badResponse:
        return '服务器异常，请稍后重试！';
      case DioExceptionType.cancel:
        return '请求已被取消，请重新请求';
      case DioExceptionType.connectionError:
        return '连接错误，请检查网络设置';
      case DioExceptionType.connectionTimeout:
        return '网络连接超时，请检查网络设置';
      case DioExceptionType.receiveTimeout:
        return '响应超时，请稍后重试！';
      case DioExceptionType.sendTimeout:
        return '发送请求超时，请检查网络设置';
      case DioExceptionType.unknown:
        return '网络异常！';
    }
  }
}
