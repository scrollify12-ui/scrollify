import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://scrollify-backend.onrender.com/api/',
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
  ));

  try {
    print('Calling endpoint...');
    final response = await dio.get(
      'users/check-username',
      queryParameters: {'username': 'test'},
    );
    print('Status Code: \${response.statusCode}');
    print('Data: \${response.data}');
  } catch (e) {
    if (e is DioException) {
      print('DioError: \${e.message}');
      print('Response Status: \${e.response?.statusCode}');
      print('Response Data: \${e.response?.data}');
    } else {
      print('Error: \$e');
    }
  }
}
