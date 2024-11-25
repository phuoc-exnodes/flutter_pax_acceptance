import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../terminal_setting_controller.dart';

class TerminalConnectedBlock extends GetView<TerminalSettingController> {
  const TerminalConnectedBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Terminal is Connected',
                  style: TextStyle(fontSize: 32),
                ),
                Icon(
                  Icons.check_circle_outline_outlined,
                  color: Colors.green,
                  size: 150,
                )
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    controller.onDisconnectTap();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.pink),
                    child: const Text(
                      'Disconnect',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ]);
  }
}
