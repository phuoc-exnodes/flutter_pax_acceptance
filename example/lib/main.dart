import 'package:dio/dio.dart';
import 'package:example/blocks/connect_terminal_block.dart';
import 'package:example/blocks/pair_terminal_block.dart';
import 'package:example/blocks/terminal_connected_block.dart';
import 'package:example/evironment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pax_acceptance/flutter_pax_acceptance.dart';

import 'network/interceptor/http_signature_interceptor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterPaxAcceptance _paxAcceptance = FlutterPaxAcceptance();
  late int _paxState;

  String _stateName = '';
  String _posID = '1111';

  final TextEditingController rootCACtr = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    getServiceState();
    _paxAcceptance.addListener(getServiceState);
    super.initState();
  }

  setLoading(bool newValue) {
    if (mounted) {
      setState(() {
        loading = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            children: [
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'TERMINAL STATE',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      _stateName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            if (loading) {
                              return;
                            }
                            setLoading(true);
                            await _paxAcceptance.refresh();
                            setLoading(false);
                          },
                          child: const Text('Refresh')),
                      const SizedBox(width: 10),
                      ElevatedButton(
                          onPressed: () {
                            _paxAcceptance.unPair();
                          },
                          child: const Text('Unpair')),
                    ],
                  )
                ],
              ),
              Expanded(child: Builder(
                builder: (context) {
                  if (loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  switch (_paxState) {
                    case FlutterPaxAcceptance.notInitialized:
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                if (loading) {
                                  return;
                                }
                                setLoading(true);
                                await _paxAcceptance.initialize(
                                  onGetRootCA: onGetRootCA,
                                );
                                setLoading(false);
                              },
                              child: const Text('Init')),
                        ],
                      );
                    case FlutterPaxAcceptance.notReady:
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                if (loading) {
                                  return;
                                }
                                setLoading(true);
                                // final success =
                                // await _paxAcceptance.setRootCA('asdw');
                                // if (!success) {
                                //   ScaffoldMessenger.maybeOf(context)
                                //       ?.showSnackBar(const SnackBar(
                                //           content:
                                //               Text('Failed to Set rootCA ')));
                                // }

                                _paxAcceptance.onGetRootCA = onGetRootCA;
                                final success = await _paxAcceptance.refresh();

                                setLoading(false);
                              },
                              child: const Text('Set rootCA ')),
                        ],
                      );
                    case FlutterPaxAcceptance.notPaired:
                      return PairTerminalBlockView(_paxAcceptance);
                    case FlutterPaxAcceptance.disconnected:
                      return ConnectTerminalBlock(
                        paxAcceptance: _paxAcceptance,
                      );
                    case FlutterPaxAcceptance.connected:
                      return TerminalConnectedBlock(_paxAcceptance);
                    default:
                      return Column(
                        children: [
                          const Expanded(
                              child: Center(
                            child: Text('Terminal Is processing Request'),
                          )),
                          SizedBox(
                            height: 100,
                            child: ElevatedButton(
                                onPressed: () {
                                  _paxAcceptance.cancelProcessing();
                                },
                                child: const Text('Cancel Processing')),
                          ),
                        ],
                      );
                  }
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  void getServiceState() {
    debugPrint('Notified: ${_paxAcceptance.state}');
    setState(() {
      _paxState = _paxAcceptance.state;

      switch (_paxAcceptance.state) {
        case FlutterPaxAcceptance.connected:
          _stateName = 'connected';
          break;
        case FlutterPaxAcceptance.disconnected:
          _stateName = 'disconnected';
          break;
        case FlutterPaxAcceptance.notReady:
          _stateName = 'notReady';
          break;
        case FlutterPaxAcceptance.notPaired:
          _stateName = 'notPaired';
          break;
        default:
      }
    });
  }

  Future<String?> onGetRootCA() async {
    try {
      //Fetching rootCA,
      final Dio dio = Dio(BaseOptions(baseUrl: EvironmentDev.baseUrl));
      dio.interceptors.add(HttpSignatureInterceptor());
      final response = await dio.get(
        EvironmentDev.getRootCA,
        data: null,
      );
      final rootCA = response.data['certificateChain'];
      if (response.statusCode != 200 && rootCA == null) {
        return null;
      }
      //Replace with your rootCA

      debugPrint('Successful saveRootCA: ${response.data}');
      debugPrint(
          'Successful saveRootCA type: ${response.data['certificateChain'].runtimeType}');
      return rootCA;
    } catch (e) {
      debugPrint('error: $e');
      return null;
    }
  }
}
