import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_ws_client/features/terminal/pax_terminal_service/pax_terminal_service.dart';
import 'package:simple_ws_client/features/terminal/presentation/widgets/pax_terminal_button.dart';

import '../../features/terminal/presentation/widgets/terminal_pay_button.dart';
import 'payment_controller.dart';

class ProcessPaymentScreen extends StatelessWidget {
  const ProcessPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: PaymentController(),
      builder: (controller) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            leading: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: const Icon(Icons.home)),
            actions: const [PaxTerminalButton()],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(
              () {
                if (controller.state == PaxTerminalService.loading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (controller.state == PaxTerminalService.processing) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        Obx(
                          () => Text(controller.transactionStatus.value ?? '',
                              style: const TextStyle(
                                  fontSize: 24, color: Colors.black)),
                        ),
                        FilledButton(
                            onPressed: () => controller.onCancelTap(),
                            style: const ButtonStyle(
                                shape: MaterialStatePropertyAll(
                                    RoundedRectangleBorder())),
                            child: const Text('Cancel'))
                      ],
                    ),
                  );
                }
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: controller.refCodeCtr,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text('MerchantRefCode'),
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: controller.amountCtr,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text('Amount'),
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: controller.currencyCtr,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text('Currency'),
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TerminalPayButton(() => controller.processPayment()),
                      FilledButton(
                          onPressed: () => controller.onCancelTap(),
                          style: const ButtonStyle(
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder())),
                          child: const Text('Cancel')),
                      SizedBox(
                        height: 300,
                        child: SingleChildScrollView(
                          child: Obx(
                            () => SelectableText(
                                controller.lastDetails.value ?? '',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.black)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
