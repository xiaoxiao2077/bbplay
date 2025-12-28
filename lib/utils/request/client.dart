import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import './cookie.dart';
import './signer.dart';
import './identify.dart';

class DioClient {
  final Dio client;

  DioClient._(this.client);

  static Future<DioClient> getInstance({
    required String baseUrl,
    bool widthSigner = false,
    Map<String, String>? headers,
  }) async {
    var cookieManager = await RequestCookie.getManager();
    final defaultHeaders = {
      'user-agent': _getUserAgent(),
      'env': 'prod',
      'referer': 'https://www.bilibili.com/'
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    final options = BaseOptions(
      connectTimeout: const Duration(milliseconds: 12000),
      receiveTimeout: const Duration(milliseconds: 12000),
      headers: defaultHeaders,
      baseUrl: baseUrl,
    );

    Dio client = Dio(options);
    List<Interceptor> interceptors = [
      cookieManager,
      IdentifyInterceptor(),
    ];
    if (widthSigner) {
      interceptors.add(RequestInterceptor());
    }
    if (kDebugMode) {
      interceptors.add(LogInterceptor(
        request: false,
        requestHeader: false,
        responseHeader: false,
      ));
    }
    // 添加拦截器
    client.interceptors.addAll(interceptors);

    // 设置后台转换器
    client.transformer = BackgroundTransformer();
    return DioClient._(client);
  }

  /// GET 请求
  Future<dynamic> get(
    String path,
    Map<String, dynamic>? query, {
    bool rawoutput = false,
  }) async {
    final response = await client.get(path, queryParameters: query);
    return rawoutput ? response : response.data;
  }

  /// POST 请求
  Future<Response> post(
    String path,
    Object? data, {
    Options? options,
  }) {
    // 在请求选项中传递 dio_client 实例，供拦截器使用
    final finalOptions = (options ?? Options())
      ..extra = {
        ...?options?.extra,
      };

    final requestOptions = finalOptions
      ..contentType = options?.contentType ?? Headers.formUrlEncodedContentType;

    return client.post(
      path,
      data: data,
      options: requestOptions,
    );
  }

  /// PUT 请求
  Future<Response> put(String path, {Object? data}) {
    return client.put(path, data: data);
  }

  /// DELETE 请求
  Future delete(
    String path,
    Map<String, dynamic>? query,
  ) {
    return client.delete(path, queryParameters: query);
  }

  /// 获取 User-Agent
  static String _getUserAgent() {
    if (Platform.isIOS) {
      return 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1 Mobile/15E148 Safari/604.1';
    } else if (Platform.isAndroid) {
      return 'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.101 Mobile Safari/537.36';
    } else {
      return 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.2 Safari/605.1.15';
    }
  }
}
