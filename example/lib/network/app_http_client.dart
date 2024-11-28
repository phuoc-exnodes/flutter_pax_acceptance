import 'dart:convert';
import 'dart:io';

class AppHttpClient {
  static final AppHttpClient _instance = AppHttpClient._internal();

  factory AppHttpClient() {
    return _instance;
  }

  AppHttpClient._internal();

  HttpClient noVerification() {
    final secureContext = SecurityContext();

    final httpClient = HttpClient(context: secureContext);

    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      return true;
    };

    return httpClient;
  }

  static HttpClient forPax(
      {required String privateCert, required String rootCA}) {
    final secureContext = SecurityContext(withTrustedRoots: true);
    secureContext.useCertificateChainBytes(utf8.encode(privateCert));
    secureContext.setTrustedCertificatesBytes(utf8.encode(rootCA));
    secureContext.usePrivateKeyBytes(utf8.encode(privateCert));

    final httpClient = HttpClient(context: secureContext);
    httpClient.connectionTimeout = const Duration(seconds: 15);
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

    return httpClient;
  }
}
