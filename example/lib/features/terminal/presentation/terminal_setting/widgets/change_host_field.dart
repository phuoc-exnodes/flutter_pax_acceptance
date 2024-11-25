import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_ws_client/features/terminal/presentation/terminal_setting/terminal_setting_controller.dart';

class ChangeHostField extends GetView<TerminalSettingController> {
  const ChangeHostField({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final enabled = controller.oldHost.value != controller.newHost.value &&
          controller.errors[ConnectTerminalError.ip] == null;
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.paxIPController,
              onChanged: controller.onHostInputChange,
              onSubmitted: (value) => controller.onSaveHostTap(),
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  errorText: controller.errors[ConnectTerminalError.ip],
                  label: const Text("IP Address")),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          FilledButton(
              onPressed: () => enabled ? controller.onSaveHostTap() : {},
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                      enabled ? Colors.pink : Colors.pink[50]),
                  shape:
                      const MaterialStatePropertyAll(RoundedRectangleBorder())),
              child: const Text('Save'))
        ],
      );
    });
  }
}
