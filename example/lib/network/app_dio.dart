import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:example/evironment.dart';

import 'app_http_client.dart';
import 'interceptor/http_signature_interceptor.dart';

class AppDio {
  static final AppDio _instance = AppDio._internal();

  factory AppDio() {
    return _instance;
  }

  AppDio._internal();

  Dio create(
      {String? baseUrl = EvironmentDev.baseUrl,
      bool disableTimeout = false,
      Duration timeout = const Duration(seconds: 15),
      bool withHttpSignature = true,
      bool certificateVerification = true}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl!,
        receiveDataWhenStatusError: true,
        persistentConnection: true,
        sendTimeout: disableTimeout ? null : timeout,
        connectTimeout: disableTimeout ? null : timeout,
        receiveTimeout: disableTimeout ? null : timeout,
      ),
    );

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () => certificateVerification
          ? AppHttpClient().noVerification()
          : AppHttpClient().noVerification(),
    );

    if (withHttpSignature) {
      dio.interceptors.add(HttpSignatureInterceptor());
    }
    dio.interceptors.addAll([
      LogInterceptor(
          requestBody: true, responseHeader: false, responseBody: true),
    ]);
    return dio;
  }
}
