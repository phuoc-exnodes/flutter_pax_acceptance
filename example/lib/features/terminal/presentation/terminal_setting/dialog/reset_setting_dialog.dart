import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetSettingDialog extends StatelessWidget {
  const ResetSettingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Warning'),
      content: const Text('Are you sure want to reset setting ?'),
      actions: [
        TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: const Text('cancel')),
        TextButton(
            onPressed: () {
              Get.back(result: true);
            },
            child: const Text('Accept')),
      ],
    );
  }
}
