import 'package:dio/dio.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/data/services/local_storage_service.dart';

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
          // Lấy token từ local storage
          final token = await _localStorage.getToken();

          // Nếu có token, thêm vào Authorization header
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        // onResponse: (response, handler) {
        //   print(
        //     'RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}',
        //   );
        //   return handler.next(response);
        // },
        // onError: (error, handler) {
        //   print(
        //     'ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}',
        //   );
        //   print('Error: ${error.response?.data}');
        //   return handler.next(error);
        // },
      ),
    );
  }

  Future<Response> put(String endpoint, dynamic data) async {
    return await dio.put(endpoint, data: data);
  }

  Future<Response> post(String endpoint, dynamic data) async {
    return await dio.post(endpoint, data: data);
  }

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await dio.get(endpoint, queryParameters: queryParameters);
  }
}
