import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_ws_client/features/terminal/data/data_source/local_terminal_ds.dart';
import 'package:simple_ws_client/features/terminal/data/repository/payzli_payment_pax.dart';
import 'package:simple_ws_client/features/terminal/domain/models/amount_details.dart';
import 'package:simple_ws_client/features/terminal/domain/models/sale_payment_request.dart';
import 'package:simple_ws_client/features/terminal/pax_terminal_service/pax_terminal_service.dart';
import 'package:simple_ws_client/presentation/refund_payment/refund_payment_screen.dart';

class PaymentController extends GetxController {
  final service = Get.find<PaxTerminalService>();

  final TextEditingController refCodeCtr = TextEditingController();
  final TextEditingController amountCtr = TextEditingController(text: '1.00');
  final TextEditingController currencyCtr = TextEditingController(text: 'USD');

  WebSocket? connection;

  int get state => service.state;

  final RxnString transactionStatus = RxnString();

  final RxnString lastDetails = RxnString();

  Future<void> processPayment() async {
    if (service.state == PaxTerminalService.processing) {
      return;
    }
    final request = SalePaymentRequest(
        merchantReferenceCode: refCodeCtr.text.isEmpty
            ? Random().nextInt(9999).toString()
            : refCodeCtr.text,
        amountDetails: AmountDetails.sale(
          currency: currencyCtr.text,
          amount: amountCtr.text,
        ));
    PayzliPaymentPAX(service).transactionSale(
      request,
      onDoneApproved: (response) {
        final id = response.transactionDetails.id;
        LocalTerminalDS().saveTransactionId(id);
        _showSnackbar('Payment Success');
        Get.find<RefundPaymentController>().getDetails();
      },
      onDoneAborted: (response) {
        _showSnackbar('Payment aborted');
      },
      onStatus: (response) {
        transactionStatus.value = response.message;
      },
    );
  }

  void onCancelTap() {
    service.cancelProcessing();
  }

  void _showSnackbar(String content) {
    Get.snackbar('PaymentResponse', content);
  }
}
