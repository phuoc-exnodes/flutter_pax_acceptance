import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../terminal_setting_controller.dart';
import '../views/connect_terminal_view.dart';

class TerminalNotPairedBlock extends GetView<TerminalSettingController> {
  const TerminalNotPairedBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Terminal not paired',
            style: TextStyle(fontSize: 24),
          ),
          GestureDetector(
            onTap: () {
              Get.to(const ConnectTerminalBlockView());
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.pink[400],
                  borderRadius: BorderRadius.circular(4)),
              child: const Text(
                'Pair',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ]);
  }
}
