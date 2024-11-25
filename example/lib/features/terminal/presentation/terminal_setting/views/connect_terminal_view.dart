import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../terminal_setting_controller.dart';

class ConnectTerminalBlockView extends GetView<TerminalSettingController> {
  const ConnectTerminalBlockView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Obx(
          () {
            if (controller.pageState.value == TerminalSettingStatus.loading) {
              return Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    OutlinedButton(
                        onPressed: () {
                          controller.onCancelPairTap();
                        },
                        child: const Text('Cancel'))
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Connect terminal',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Obx(
                              () => TextField(
                                controller: controller.paxIPController,
                                focusNode: controller.paxIPFieldNode,
                                enabled: controller.pageState.value !=
                                    TerminalSettingStatus.loading,
                                inputFormatters: [
                                  TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                      final newtext = newValue.text.trim();
                                      return newValue.copyWith(text: newtext);
                                    },
                                  ),
                                ],
                                decoration: const InputDecoration(
                                    label: Text('Enter PAX IP and Port'),
                                    hintText: 'IP:PORT',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder()),
                                onEditingComplete: () =>
                                    controller.paxCodeFieldNode.requestFocus(),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Obx(
                              () => TextField(
                                controller: controller.paxCodeController,
                                focusNode: controller.paxCodeFieldNode,
                                enabled: controller.pageState.value !=
                                    TerminalSettingStatus.loading,
                                decoration: const InputDecoration(
                                    label: Text('Enter code'),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.onPairTap(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.pink[300],
                            borderRadius: BorderRadius.circular(4)),
                        child: const Text(
                          'Connect',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ]),
            );
          },
        ),
      ),
    );
  }
}
