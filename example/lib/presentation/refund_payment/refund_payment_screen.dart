import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_ws_client/features/terminal/data/data_source/local_terminal_ds.dart';
import 'package:simple_ws_client/features/terminal/data/repository/payzli_payment_pax.dart';
import 'package:simple_ws_client/features/terminal/domain/models/amount_details.dart';
import 'package:simple_ws_client/features/terminal/domain/models/refund_request.dart';
import 'package:simple_ws_client/features/terminal/pax_terminal_service/pax_terminal_service.dart';

class RefundPaymentScreen extends StatelessWidget {
  const RefundPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const buttonStyle = ButtonStyle(
        shape: MaterialStatePropertyAll(RoundedRectangleBorder()),
        padding: MaterialStatePropertyAll(EdgeInsets.all(10)));
    return GetBuilder(
      init: Get.put<RefundPaymentController>(RefundPaymentController()),
      builder: (controller) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Refund Transaction'),
                FilledButton(
                    onPressed: () async {
                      controller.getDetails();
                    },
                    style: buttonStyle,
                    child: const Text(
                      'refresh',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    )),
                FilledButton(
                  onPressed: () => controller.onClearAllTap(),
                  style: const ButtonStyle(
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(),
                    ),
                  ),
                  child: const Text('Clear ALL'),
                ),
              ],
            ),
            Expanded(
              child: Obx(() {
                if (controller.state == RxStatus.loading()) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final details = controller.details.value;
                if (details.isEmpty) {
                  return const Center(
                    child: Text('Empty transaction historyi'),
                  );
                }
                return ListView.builder(
                  itemCount: details.length,
                  itemBuilder: (context, index) => Row(
                    children: [
                      Text(details[index]),
                      FilledButton(
                        onPressed: () =>
                            controller.processRefund(details[index]),
                        style: const ButtonStyle(
                          shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(),
                          ),
                        ),
                        child: const Text('Refund'),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ]),
        );
      },
    );
  }
}

class RefundPaymentController extends GetxController {
  final service = Get.find<PaxTerminalService>();

  final details = List<String>.empty().obs;
  final _state = RxStatus.loading().obs;
  RxStatus get state => _state.value;

  @override
  void onInit() {
    getDetails();
    super.onInit();
  }

  void getDetails() async {
    final result = await LocalTerminalDS().getIds();
    details.value = result ?? List.empty();
    _state.value = RxStatus.success();
  }

  processRefund(String id) {
    final request = RefundRequest(
      transactionId: id,
      amountDetails:
          const AmountDetails.refund(currency: 'USD', amount: '1.00'),
    );

    PayzliPaymentPAX(service).refund(
      request,
      onDoneApproved: (response) {
        _showSnackbar('Refund approved');
        LocalTerminalDS().deleteID(id);
        getDetails();
        _state.value = RxStatus.success();
      },
      onDoneAborted: (response) {
        _showSnackbar('Refund aborted');

        _state.value = RxStatus.success();
      },
      onStatus: (response) {},
    );
  }

  void _showSnackbar(String content) {
    Get.snackbar('PaymentResponse', content);
  }

  onClearAllTap() async {
    await LocalTerminalDS().clearIDS();
    getDetails();
  }
}
