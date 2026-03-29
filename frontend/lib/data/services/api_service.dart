import 'package:dio/dio.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/data/services/local_storage_service.dart';
import 'package:frontend/core/utils/logger.dart';

class ApiService {
  late final Dio dio;
  final LocalStorageService _localStorage = LocalStorageService();

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Interceptor để tự động thêm token vào mỗi request
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.baseUrl = ApiConstants.baseUrl;
          logger.i('REQUEST => ${options.baseUrl}${options.path}');

          // Lấy token từ local storage
          final token = await _localStorage.getToken();

          // Nếu có token, thêm vào Authorization header
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          logger.i(
            'RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          logger.e(
            'ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}',
          );
          logger.e('Error: ${error.response?.data}');
          logger.e('Dio type: ${error.type}, message: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> put(String endpoint, dynamic data) async {
    return await dio.put(endpoint, data: data);
  }

  Future<Response> patch(String endpoint, dynamic data) async {
    return await dio.patch(endpoint, data: data);
  }

  Future<Response> patchFormData(String endpoint, FormData data) async {
    return await dio.patch(
      endpoint,
      data: data,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
  }

  Future<Response> post(String endpoint, dynamic data) async {
    if (data is FormData) {
      return await dio.post(
        endpoint,
        data: data,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
    }

    return await dio.post(endpoint, data: data);
  }

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await dio.get(endpoint, queryParameters: queryParameters);
  }

  Future<Response> delete(String endpoint) async {
    return await dio.delete(endpoint);
  }
}
