import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_ws_client/features/terminal/pax_terminal_service/pax_terminal_service.dart';
import 'package:simple_ws_client/presentation/process_payment/process_payment_screen.dart';

import '../features/terminal/presentation/widgets/pax_terminal_button.dart';
import 'refund_payment/refund_payment_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final response = ''.obs;

  @override
  void initState() {
    initPaxService();

    super.initState();
  }

  void initPaxService() {
    Get.put(PaxTerminalService()).init();
  }

  @override
  Widget build(BuildContext context) {
    const buttonStyle = ButtonStyle(
        shape: MaterialStatePropertyAll(RoundedRectangleBorder()),
        padding: MaterialStatePropertyAll(EdgeInsets.all(10)));
    return Scaffold(
      appBar: AppBar(
        title: const PaxTerminalButton(),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton(
                      onPressed: () async {
                        Get.to(const ProcessPaymentScreen());
                      },
                      style: buttonStyle,
                      child: const Text(
                        'Create Payment',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      )),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    // Expanded(
                    //   child: CaptureAuthorizationScreen(),
                    // ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    Expanded(
                      child: RefundPaymentScreen(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
