import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

import 'models/pax_pair_request.dart';

class FlutterPaxAcceptance with ChangeNotifier {
  ///When no rootRA are found
  static const int notInitialized = 0;

  ///When no rootRA are found
  static const int notReady = 1;

  ///When no PrivateCertificateChain and Host found
  static const int notPaired = 2;

  ///When files ready but not connected to PAX's websocket
  static const int disconnected = 3;

  ///When  connected to PAX's websocket
  static const int connected = 4;

  ///When processing request
  static const int processing = 5;

  ///When doing something
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _state = notInitialized;
  int get state => _state;

  WebSocket? _connection;
  StreamSubscription? _subscription;

  String? _host;
  String? get host => _host;
  String? _rootCA;
  String? get rootCA => _rootCA;
  String? _privateCert;
  String? get privateCert => _privateCert;

  Function(dynamic data)? _onDataListener;

  ///Callback when not found local rootCA
  Future<String?> Function()? onGetRootCA;

  ///Dispose and release resources
  @override
  void dispose() {
    super.dispose();
    _onDataListener = null;
    onGetRootCA = null;
    _connection?.close();
    _subscription?.cancel();
    _connection = null;
  }

  ///init Service for specific POS with posId.
  ///Checking for files then start the connection automatically if ready
  ///
  ///Make sure using the the same posId so the nextime init can retreive correct files
  bool _isInitialized = false;
  Future<void> initialize({Future<String?> Function()? onGetRootCA}) async {
    if (_isLoading) return;
    _isLoading = true;

    if (_isInitialized) {
      debugPrint('FlutterPaxAcceptance: Already initialized');
      return;
    }
    _isInitialized = true;

    this.onGetRootCA = onGetRootCA;
    //Check for rootCA, if false, state is notReady
    if (!await _getRootCA()) {
      _setState(notReady);
      _isLoading = false;
      return;
    }
    //Check for PrivateCert and host saved, if false, state is notPaired
    if (!await _getRequiredFiles()) {
      _isLoading = false;
      return;
    }

    _isLoading = false;
    connect();
  }

  ///Call to refresh service state, include Checking files, stop Processing, reconnect,..
  Future<void> refresh() async {
    _isLoading = true;

    _connection?.close();
    _connection = null;
    _subscription?.cancel();

    if (!await _getRootCA()) {
      _isLoading = false;
      return;
    }
    await _getRequiredFiles();

    _isLoading = false;
    if (state == disconnected) {
      await connect();
    }
  }

  ///Set PAX's server rootCA, this will refesh the service state
  Future<bool> setRootCA(String ca) async {
    try {
      //Check if rootCa is valid, if not. an Exception is thrown
      SecurityContext().setTrustedCertificatesBytes(utf8.encode(ca));

      //Save the rootCA
      final success = await _LocalTerminalDS.saveRootCA(ca);
      if (success) {
        _rootCA = ca;
        await refresh();
      }
      return success;
    } catch (e) {
      debugPrint('FlutterPaxAcceptance: Error setting rootCA \n$e');
      return false;
    }
  }

  ///Pair a new PAX to use and remove old one.
  ///
  ///The posId must be a number, otherwise Pax terminal wont sync and response with status code of 500
  Future<bool> pairPAXTerminal(
      {required String ipAddress,
      required int port,
      required String setupCode}) async {
    if (state == connected || _isLoading || !_isInitialized) return false;

    if (setupCode.length < 8 || setupCode.length > 8) {
      debugPrint('FlutterPaxAcceptance: Pair Error: Invalid setupCode');
      return false;
    }
    if (!validateHost(ipAddress, port)) return false;

    _isLoading = true;

    try {
      final dio = Dio(BaseOptions(
        baseUrl: 'https://$ipAddress:$port',
        connectTimeout: const Duration(seconds: 30),
        receiveDataWhenStatusError: true,
        persistentConnection: true,
      ));

      final client = HttpClient(context: SecurityContext());
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () => client,
      );

      final pairRequest =
          PaxPairRequest(posId: '1111', setupCode: setupCode).toJson();
      final response = await dio.post('/', data: pairRequest);

      if (response.statusCode != 200 || response.data == null) {
        _isLoading = false;
        _setState(notPaired);
        return false;
      }
      final certificateChain = response.data;
      debugPrint(response.data);
      //Save Certificate and Host
      await _LocalTerminalDS.savePrivateCert(certificateChain);
      await _LocalTerminalDS.saveHost('$ipAddress:$port');

      _privateCert = certificateChain;
      _host = '$ipAddress:$port';

      _isLoading = false;
      _setState(disconnected);
      return true;
    } catch (e) {
      debugPrint('FlutterPaxAcceptance: Pair Error: $e');
      _isLoading = false;
      _setState(notPaired);
      return false;
    }
  }

  ///Unpair PAX device
  Future<void> unPair() async {
    if (state == processing || _isLoading || !_isInitialized) {
      debugPrint('Terminal Service: Terminal is processing');
      return;
    }
    _isLoading = true;

    await _connection?.close();
    _connection = null;
    _host = null;
    _privateCert = null;

    await _LocalTerminalDS.deleteCertificate();
    await _LocalTerminalDS.deleteHost();
    await refresh();
  }

  ///Connect to PAX Websocket server
  Future<bool> connect() async {
    String? error;
    if (_isLoading || state == processing || !_isInitialized) {
      error = 'FlutterPaxAcceptance: Service is loading or processing request!';
    }
    if (state == connected) {
      error = 'FlutterPaxAcceptance: Already connected, try refresh';
    }
    if (state == notReady || state == notPaired) {
      error = 'FlutterPaxAcceptance: Not ready or not paired to a PAX device';
    }
    if (error != null) {
      debugPrint(error);
      return false;
    }
    _isLoading = true;

    try {
      final secureContext = SecurityContext();
      secureContext.setTrustedCertificatesBytes(utf8.encode(rootCA!));
      secureContext.useCertificateChainBytes(utf8.encode(privateCert!));
      secureContext.usePrivateKeyBytes(utf8.encode(privateCert!));

      final httpClient = HttpClient(context: secureContext);
      httpClient.connectionTimeout = const Duration(seconds: 15);
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      _subscription?.cancel();
      _connection?.close();
      debugPrint('FlutterPaxAcceptance: Connecting to $host');

      _connection =
          await WebSocket.connect('wss://$host', customClient: httpClient);
      //If connection is aborted before establish(Calling 'cancelConnect', 'disconnect',.. )
      if (!isLoading) {
        _connection?.close();
        _subscription?.cancel();
        _connection = null;
      }

      debugPrint('FlutterPaxAcceptance: Connected');

      _subscription = _connection?.listen(
        (event) {
          _onDataListener?.call(event);
          //check the response to know if payment process has been aborted/ended
          try {
            final jsonData = jsonDecode(event);
            final isAborted =
                (jsonData['message'] as String?)?.contains('aborted') == true;
            if (isAborted || jsonData['type'] == 'ErrorResponse') {
              _setState(connected);
            }
          } catch (e) {
            debugPrint(e.toString());
          }
        },
        onDone: () {
          debugPrint('FlutterPaxAcceptance : Connection has ended');
          _setState(disconnected);
        },
        cancelOnError: true,
        onError: (error, stacktrace) {
          debugPrint('FlutterPaxAcceptance : Connection Error $error');
        },
      );
      _isLoading = false;
      _setState(connected);
      return true;
    } on Exception catch (e) {
      debugPrint('FlutterPaxAcceptance: Cannot connect to PAX terminal');
      debugPrint('FlutterPaxAcceptance: $e');
      _isLoading = false;
      _setState(disconnected);
      return false;
    }
  }

  Future<void> disconnect() async {
    await _connection?.close();
    _connection = null;
    _isLoading = false;
    _setState(disconnected);
  }

  ///Send payment request to PAX terminal Socket Server, only one listener registered at a time.
  ///If a transaction is in process, new one is skipped.
  void process(
      Map<String, dynamic> request, void Function(dynamic data)? listener) {
    if (state != connected || _connection == null || !_isInitialized) {
      debugPrint('FlutterPaxAcceptance: Terminal not connected');
      return;
    }

    if (state == processing) {
      debugPrint(
          'FlutterPaxAcceptance: Terminal is in processing, call cancelProcessing() to stop');
      return;
    }
    _setState(processing);
    _onDataListener = listener ?? _onDataListener;
    _connection!.add(jsonEncode(request));
  }

  ///Send abort request to PAX terminal to stop payment process
  void cancelProcessing() {
    if (state == processing || state == connected) {
      final abortRequest = {"type": "CancelRequest"};
      _connection?.add(jsonEncode(abortRequest));
      _setState(connected);
    }
  }

  ///Call when Payment process has completed.
  ///If not completed, call cancelProcessing() to cancel
  void completeProcessing() {
    _setState(connected);
  }

  ///Search Local Storage for RootCA,
  ///
  ///IF non found, call onGetRootCA callback,
  ///
  ///IF also non found, state is notReady
  ///
  Future<bool> _getRootCA() async {
    debugPrint('FlutterPaxAcceptance: Getting RootCA');
    try {
      String? localRootCA = await _LocalTerminalDS.loadRootCA();

      if (localRootCA != null) {
        _rootCA = localRootCA;
        return true;
      }
      //get from onGetRootCA callback
      final result = await onGetRootCA?.call();
      if (result != null) {
        SecurityContext().setTrustedCertificatesBytes(utf8.encode(result));
        _rootCA = result;
        await _LocalTerminalDS.saveRootCA(result);
        return true;
      }
      debugPrint('FlutterPaxAcceptance: RootCA not found');
      _setState(notReady);
      return false;
    } catch (e) {
      debugPrint('FlutterPaxAcceptance: Error getting RootCA');
      _setState(notReady);
      return false;
    }
  }

  ///Get required file needed when connect to PAX's websocket
  Future<bool> _getRequiredFiles() async {
    debugPrint('FlutterPaxAcceptance: Getting Cetificate Chain');
    try {
      final storedPrivateCert = await _LocalTerminalDS.loadPrivateCert();
      final storedHost = await _LocalTerminalDS.loadHost();

      if (storedPrivateCert == null || storedHost == null) {
        _setState(notPaired);
        return false;
      }

      _privateCert = storedPrivateCert;
      _host = storedHost;

      _setState(disconnected);
      return true;
    } catch (e) {
      _setState(notPaired);
      return false;
    }
  }

  void _setState(int newState) {
    _state = newState;
    switch (state) {
      case notPaired:
        debugPrint('FlutterPaxAcceptance: Not paired');

        break;
      case disconnected:
        debugPrint('FlutterPaxAcceptance: Disconnected');

        break;
      case connected:
        debugPrint('FlutterPaxAcceptance: Connected');
        break;
      case processing:
        debugPrint('FlutterPaxAcceptance: Processing');
        break;
    }
    notifyListeners();
  }

  ///Listen to state change
  @override
  void addListener(void Function() listener) {
    super.addListener(listener);
    notifyListeners();
  }

  ///Update PAX terminal IP address
  Future<bool> setHost(String ip, int port) async {
    try {
      if (!validateHost(ip, port)) {
        return false;
      }
      String hostString = '$ip:$port';
      final success = await _LocalTerminalDS.saveHost(hostString);

      if (success) {
        _host = hostString;
      }
      return success;
    } catch (e) {
      debugPrint('Invalid host');
      return false;
    }
  }

  bool validateHost(String ipAddress, int port) {
    final ipv4Regex = RegExp(
        r'^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[1-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])$');
    if ((!ipv4Regex.hasMatch(ipAddress) || !(port >= 1 && port <= 65535))) {
      debugPrint('FlutterPaxAcceptance: Invalid IP and Port');
      return false;
    }
    return true;
  }
}

class _LocalTerminalDS {
  static const String privateCertificate = '/private_certificate.pem';
  static const String rootCAPath = '/root_ca.pem';
  static const String terminalUrl = '/terminal_url.txt';

  static Future<bool> saveRootCA(
    String cert,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final file = File(directory.path + rootCAPath);
      await file.writeAsString(cert);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> savePrivateCert(
    String cert,
  ) async {
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

  static Future<bool> saveHost(
    String host,
  ) async {
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
}
