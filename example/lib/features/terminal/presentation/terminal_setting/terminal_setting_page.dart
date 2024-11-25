import 'package:example/features/terminal/presentation/terminal_setting/blocks/terminal_connected_block%20copy.dart';
import 'package:example/features/terminal/presentation/terminal_setting/blocks/terminal_not_paired_block.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'blocks/terminal_not_connected_block.dart';
import 'blocks/terminal_not_ready.dart';
import 'terminal_setting_controller.dart';

class TerminalSettingPage extends StatelessWidget {
  const TerminalSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: TerminalSettingController(),
      builder: (controller) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            actions: [
              PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: TextButton(
                        onPressed: () {
                          controller.onResetTap();
                        },
                        child: const Text('Reset Settings'),
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
          body: SizedBox.expand(
            child: Obx(
              () {
                print(controller.pageState.value);
                switch (controller.pageState.value) {
                  case TerminalSettingStatus.loading:
                    {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                          TextButton(
                              onPressed: () {
                                controller.onCancelConnectTap();
                              },
                              child: const Text('Cancel'))
                        ],
                      );
                    }
                  case TerminalSettingStatus.notReady:
                    return const TerminalNotReadyBlock();
                  case TerminalSettingStatus.notPaired:
                    return const TerminalNotPairedBlock();
                  case TerminalSettingStatus.disconnected:
                    return const TerminalDisonnectedBlock();

                  case TerminalSettingStatus.connected:
                    return const TerminalConnectedBlock();
                  case TerminalSettingStatus.processing:
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Terminal is processing payment'),
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
