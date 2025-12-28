import 'dart:convert';
import 'package:dio/dio.dart';

import '/utils/loggy.dart';
import '/utils/dbhelper.dart';
import '/utils/request/client.dart';

/// 服务基类
class BaseService {
  static DioClient? _apiClient;
  static DioClient? _baseClient;
  static DioClient? _passportClient;
  static DioClient? _searchClient;
  static DBHelper dbHelper = DBHelper();

  static Future<DioClient> getBaseClient() async {
    if (_baseClient != null) {
      return _baseClient!;
    }
    String baseUrl = 'https://bbplay.xiaoxiaov.com';

    final tempDio = Dio(BaseOptions(
      followRedirects: false,
      validateStatus: (status) {
        return status != null && status < 400;
      },
    ));
    final response = await tempDio.get(baseUrl);
    if (response.statusCode == 301 || response.statusCode == 302) {
      baseUrl = response.headers.value('location')!;
    }
    _baseClient = await DioClient.getInstance(
      baseUrl: baseUrl,
      widthSigner: true,
    );

    return _baseClient!;
  }

  static Future<DioClient> getApiClient() async {
    _apiClient ??= await DioClient.getInstance(
      baseUrl: 'https://api.bilibili.com',
      widthSigner: false,
    );
    return _apiClient!;
  }

  static Future<DioClient> getPassportClient() async {
    _passportClient ??= await DioClient.getInstance(
      baseUrl: 'https://passport.bilibili.com',
      widthSigner: false,
    );
    return _passportClient!;
  }

  static Future<DioClient> getSearchClient() async {
    _searchClient ??= await DioClient.getInstance(
      baseUrl: 'https://s.search.bilibili.com',
      widthSigner: false,
    );
    return _searchClient!;
  }

  static Future<ApiResponse<T>> get<T>(
    DioClient client,
    String path, {
    Map<String, dynamic>? params,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await client.get(path, params, rawoutput: true);
      return _handleResponse<T>(response, parser);
    } catch (e, stackTrace) {
      Loggy.e("get error", e, stackTrace);
      return ApiResponse.error('网络请求失败: $e');
    }
  }

  static Future<ApiResponse<T>> post<T>(
    DioClient client,
    String path, {
    Object? data,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await client.post(
        path,
        data,
      );
      return _handleResponse<T>(response, parser);
    } catch (e, stackTrace) {
      Loggy.e("post error", e, stackTrace);
      return ApiResponse.error('网络请求失败: $e');
    }
  }

  static Future<ApiResponse<T>> put<T>(
    DioClient client,
    String path, {
    Object? data,
    Map<String, dynamic>? params,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await client.put(path, data: data);
      return _handleResponse<T>(response, parser);
    } catch (e, stackTrace) {
      Loggy.e(e, stackTrace);
      return ApiResponse.error('网络请求失败: $e');
    }
  }

  static Future<ApiResponse<T>> delete<T>(
    DioClient client,
    String path, {
    Object? data,
    Map<String, dynamic>? params,
    T Function(dynamic)? parser,
  }) async {
    try {
      final client = await getBaseClient();
      final response = await client.delete(path, params);
      return _handleResponse<T>(response, parser);
    } catch (e, stackTrace) {
      Loggy.e("delete error", e, stackTrace);
      return ApiResponse.error('网络请求失败: $e');
    }
  }

  static ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? parser,
  ) {
    if (response.data.runtimeType == String) {
      response.data = jsonDecode(response.data);
    }
    if (response.data['code'] == 0) {
      if (parser != null) {
        try {
          final parsedData = parser(response.data['data']);
          return ApiResponse.success(parsedData);
        } catch (e, stack) {
          Loggy.e("_handleResponse", e, stack);
          return ApiResponse.error('数据解析失败: $e');
        }
      } else {
        try {
          return ApiResponse.success(response.data['data'] as T);
        } catch (e) {
          return ApiResponse.error('数据类型转换失败: $e');
        }
      }
    } else {
      return ApiResponse.error(response.data['message'] as String);
    }
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse(success: true, data: data);
  }

  factory ApiResponse.error(String message) {
    return ApiResponse(success: false, message: message);
  }

  @override
  String toString() {
    return 'ApiResponse{success: $success, data: $data, message: $message}';
  }
}
