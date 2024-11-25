library flutter_pax_acceptance;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class FlutterPaxAcceptance with ChangeNotifier {
  static const int notReady = 0;
  static const int notPaired = 1;
  static const int disconnected = 2;
  static const int connected = 3;
  static const int loading = 4;
  static const int processing = 5;
  // static const int errorState = 5;

  // ignore: prefer_final_fields
  int _state = loading;
  int get state => _state;

  WebSocket? _connection;

  String? host;
  String? rootCA;
  String? privateCert;

  Function(dynamic data)? onDataListener;

  ///init service for PAX terminal.
  Future<void> init() async {
    await checkState();
    if (state == disconnected) {
      connect();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _connection?.close();
  }

  /// Check all requirements to know which state the Service is met
  Future<void> checkState() async {
    _setState(loading);
    if (!await _getRootCA()) return;
    if (!await _getRequiredFiles()) {
      return;
    }
    if (_connection != null && _connection!.readyState == WebSocket.open) {
      _setState(connected);
      return;
    }
    _setState(disconnected);
    return;
  }

  //Pair a new PAX to use and remove old one
  Future<bool> pair(
      {required String host,
      required String posId,
      required String setupCode}) async {
    if (state == connected) {
      return false;
    }
    _setState(loading);
    try {
      final dio = Dio(BaseOptions(
        baseUrl: "https://$host",
        connectTimeout: const Duration(seconds: 30),
      ));

      final response =
          await dio.post('/', data: {'posId': posId, 'setupCode': setupCode});

      if (response.statusCode != 200 || response.data == null) {
        _setState(notPaired);
        return false;
      }
      final certificateChain = response.data;
      debugPrint(response.data);
      await _LocalTerminalDS.savePrivateCert(certificateChain);
      await _LocalTerminalDS.saveHost(host);

      privateCert = certificateChain;
      this.host = host;

      _setState(disconnected);
      return true;
    } catch (e) {
      _setState(notPaired);
      return false;
    }
  }

  Future<bool> connect() async {
    if (state == loading || state == processing) return false;

    if (state != disconnected) {
      return false;
    }
    if (_connection != null || _connection?.readyState == WebSocket.open) {
      debugPrint('PaxTerminalService: Already connected, try refresh');
      return false;
    }
    if (rootCA == null || privateCert == null || host == null) {
      debugPrint('No Root CA or Private Certificate found');
      return false;
    }
    _setState(loading);

    try {
      debugPrint(host);
      final secureContext = SecurityContext(withTrustedRoots: true);
      secureContext.useCertificateChainBytes(utf8.encode(privateCert!));
      secureContext.setTrustedCertificatesBytes(utf8.encode(rootCA!));
      secureContext.usePrivateKeyBytes(utf8.encode(privateCert!));

      final httpClient = HttpClient(context: secureContext);
      httpClient.connectionTimeout = const Duration(seconds: 15);
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      _connection =
          await WebSocket.connect('wss://$host', customClient: httpClient);
      //If connection is aborted before establish(Calling 'cancelConnect', 'disconnect',.. )
      if (state == disconnected) {
        _connection?.close();
      }
      _setState(connected);

      _connection?.listen(
          (event) {
            onDataListener?.call(event);
            //check the response to know if payment process has been aborted/ended
            try {
              final jsonData = jsonDecode(event);
              if ((jsonData['message'] as String?)?.contains('aborted') ==
                      true ||
                  jsonData['type'] == 'ErrorResponse') {
                _setState(connected);
              }
            } catch (e) {
              debugPrint(e.toString());
            }
          },
          onDone: () {
            debugPrint('PaxTerminalService : Done');
            _setState(disconnected);
          },
          cancelOnError: true,
          onError: (error, stacktrace) {
            debugPrint('PaxTerminalService : Error $error');
          });

      return true;
    } on Exception catch (e) {
      _setState(disconnected);
      debugPrint('PaxTerminalService: Cannot connect to PAX terminal');
      debugPrint('PaxTerminalService: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    await _connection?.close();
    _connection = null;
    _setState(disconnected);
  }

  ///Send payment request to PAX terminal, only one listener registered at a time.
  ///If a transaction is in process, new one is skipped.
  void process(
      Map<String, dynamic> request, void Function(dynamic data)? listener) {
    if (state != connected || _connection == null) {
      debugPrint('Terminal Service: Terminal not connected');
      return;
    }

    if (state == processing) {
      debugPrint('Terminal Service: Terminal is processing');
      return;
    }
    _setState(processing);
    onDataListener = listener ?? onDataListener;
    _connection!.add(jsonEncode(request));
  }

  ///Send abort request to PAX terminal to stop payment process
  void cancelProcessing() {
    if (state == processing || state == connected) {
      final request = {"type": "CancelRequest"};
      _connection!.add(jsonEncode(request));
    }
  }

  ///Manually cancel payment processing.
  ///
  ///Should be call at the end of each payment request to ensure
  ///Service able to process new payment request
  void completeProcessing() {
    _setState(connected);
    checkState();
  }

  ///Unpair PAX device
  Future<void> resetSetting() async {
    if (state == processing) {
      debugPrint('Terminal Service: Terminal is processing');
      return;
    }
    _setState(loading);

    await _connection?.close();
    _connection = null;

    host = null;

    privateCert = null;
    await _LocalTerminalDS.deleteCertificate();
    await _LocalTerminalDS.deleteHost();
    _setState(notPaired);
  }

  ///Get PAX's rootCA
  Future<bool> _getRootCA() async {
    try {
      String? localRootCA = await _LocalTerminalDS.loadRootCA();

      debugPrint('localRootCA ${localRootCA != null}');

      if (localRootCA == null) {
        _setState(notReady);
        return false;
      }
      rootCA = localRootCA;

      _setState(notReady);
      return true;
    } catch (e) {
      _setState(notReady);
      return false;
    }
  }

  ///Get required file needed when connect to PAX's websocket
  Future<bool> _getRequiredFiles() async {
    final storedPrivateCert = await _LocalTerminalDS.loadPrivateCert();
    final storedHost = await _LocalTerminalDS.loadHost();

    debugPrint('storedPrivateCert ${storedPrivateCert != null}');
    debugPrint('storedHost $storedHost');

    if (storedPrivateCert == null || storedHost == null) {
      _setState(notPaired);
      return false;
    }

    try {
      privateCert = storedPrivateCert;
      host = storedHost;
      _setState(disconnected);
      return true;
    } catch (e) {
      _setState(notPaired);
      return false;
    }
  }

  void _setState(int newState) {
    final oldState = state;
    _state = newState;
    switch (state) {
      case notPaired:
        debugPrint('PaxTerminalService: Not paired');

        break;
      case disconnected:
        debugPrint('PaxTerminalService: Disconnected');

        break;
      case connected:
        debugPrint('PaxTerminalService: Connected');
        break;
      case loading:
        {
          Future.delayed(const Duration(seconds: 30)).then((value) {
            if (state == loading) {
              _state = oldState;
            }
          });
        }
        break;
    }
    notifyListeners();
  }

  ///Update host when switching wifi/local network
  Future<bool> saveHost(String newHost) async {
    try {
      final success = await _LocalTerminalDS.saveHost(newHost);

      if (success) {
        host = newHost;
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  @override
  void addListener(VoidCallback listener) {
    // TODO: implement addListener
  }

  @override
  void removeListener(VoidCallback listener) {
    // TODO: implement removeListener
  }
}

class _LocalTerminalDS {
  static const String privateCertificate = '/private_certificate.pem';
  static const String rootCAPath = '/root_ca.pem';
  static const String terminalUrl = '/terminal_url.txt';

  static Future<bool> saveRootCA(String cert) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final file = File(directory.path + rootCAPath);
      await file.writeAsString(cert);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> savePrivateCert(String cert) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final file = File(directory.path + privateCertificate);
      await file.writeAsString(cert);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> loadRootCA() async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final file = File(directory.path + rootCAPath);
      return file.readAsStringSync();
    } catch (e) {
      return null;
    }
  }

  static Future<String?> loadPrivateCert() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(directory.path + privateCertificate);
      return file.readAsStringSync();
    } catch (e) {
      return null;
    }
  }

  static Future<bool> saveHost(String host) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final file = File(directory.path + terminalUrl);

      await file.writeAsBytes(utf8.encode(host));
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> loadHost() async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final file = File(directory.path + terminalUrl);
      if (!file.existsSync()) return null;
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  static Future<bool> deleteCertificate() async {
    try {
      final directoryPath = (await getApplicationDocumentsDirectory()).path;
      final privateCertificateFile = File(directoryPath + privateCertificate);
      await privateCertificateFile.delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteHost() async {
    try {
      final directoryPath = (await getApplicationDocumentsDirectory()).path;
      final file = File(directoryPath + terminalUrl);
      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> clearAll() async {
    try {
      final directoryPath = (await getApplicationDocumentsDirectory()).path;

      final file = File(directoryPath + terminalUrl);
      final rootCAPathFile = File(directoryPath + rootCAPath);
      final privateCertificateFile = File(directoryPath + privateCertificate);

      await file.delete();
      await rootCAPathFile.delete();
      await privateCertificateFile.delete();

      return true;
    } catch (e) {
      return false;
    }
  }
}
