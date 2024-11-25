import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_ws_client/features/terminal/presentation/terminal_setting/widgets/change_host_field.dart';

import '../terminal_setting_controller.dart';

class TerminalDisonnectedBlock extends GetView<TerminalSettingController> {
  const TerminalDisonnectedBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: 100,
          child: Center(
            child: Text(
              'POS and Terminal not connected',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          ),
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: ChangeHostField(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: GestureDetector(
            onTap: () {
              controller.onConnectTap();
            },
            child: Container(
              height: 60,
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.pink[400],
                  borderRadius: BorderRadius.circular(4)),
              child: const Text(
                'Connect',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
