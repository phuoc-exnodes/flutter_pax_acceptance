import 'dart:convert';

import 'package:flutter_pax_acceptance/flutter_pax_acceptance.dart';

import 'models/payment_response.dart';
import 'models/refund_request.dart';
import 'models/sale_payment_request.dart';
import 'models/transaction_error_response.dart';
import 'models/transaction_status_response.dart';

class PayzliPaymentPAX extends FlutterPaxAcceptance {
  final FlutterPaxAcceptance _service;
  PayzliPaymentPAX(this._service);

  ///handle full payment
  void transactionSale(
    SalePaymentRequest request, {
    required void Function(PaymentResponse response) onDoneApproved,
    required void Function(PaymentResponse response) onDoneAborted,
    void Function(TransactionStatusResponse response)? onStatus,
    void Function(ErrorResponse response)? onErrorResponse,
    void Function(String error)? onError,
  }) {
    _service.addListener(() {
      _service.state;
    });
    //Validating requirement,...
    if (_service.state != FlutterPaxAcceptance.connected) {
      onError?.call('Pax terminal cannot handle request right now');
    }
    //validate input

    //Start processing
    _service.process(request.toJson(), (data) {
      try {
        final jsonData = jsonDecode(data);

        switch (jsonData['type']) {
          case 'TransactionStatusResponse':
            {
              final response = TransactionStatusResponse.fromJson(jsonData);
              onStatus?.call(response);
            }
            break;
          case 'PaymentResponse':
            {
              final paymentResponse = PaymentResponse.fromJson(jsonData);
              if (paymentResponse.message == 'Payment approved') {
                onDoneApproved.call(paymentResponse);
              }
              if (paymentResponse.message == 'Payment aborted') {
                onDoneApproved.call(paymentResponse);
              }
              _service.completeProcessing();
            }
            break;
          case 'ErrorResponse':
            {
              final errorResponse = ErrorResponse.fromJson(jsonData);
              onErrorResponse?.call(errorResponse);
              if (errorResponse.message == 'Transaction was aborted') {
                _service.completeProcessing();
              }
            }
            break;
          default:
        }
      } catch (e) {
        _service.completeProcessing();
        onError?.call(e.toString());
      }
    });
  }

  ///handle Refund
  void refund(
    RefundRequest request, {
    required void Function(PaymentResponse response) onDoneApproved,
    required void Function(PaymentResponse response) onDoneAborted,
    void Function(TransactionStatusResponse response)? onStatus,
    void Function(ErrorResponse response)? onErrorResponse,
    void Function(String error)? onError,
  }) {
    _service.process(request.toJson(), (data) {
      try {
        final jsonData = jsonDecode(data);
        switch (jsonData['type']) {
          case 'TransactionStatusResponse':
            {
              final response = TransactionStatusResponse.fromJson(jsonData);
              onStatus?.call(response);
            }
            break;
          case 'LinkedRefundResponse':
            {
              final paymentResponse = PaymentResponse.fromJson(jsonData);
              if (paymentResponse.message == 'Refund approved') {
                onDoneApproved.call(paymentResponse);
              }
              if (paymentResponse.message == 'Refund Aborted') {
                onDoneAborted.call(paymentResponse);
              }
              _service.completeProcessing();
            }
            break;
          case 'ErrorResponse':
            {
              final errorResponse = ErrorResponse.fromJson(jsonData);
              onErrorResponse?.call(errorResponse);
              if (errorResponse.message == 'Transaction was aborted') {
                _service.completeProcessing();
              }
            }
            break;
          default:
        }
      } catch (e) {
        onError?.call(e.toString());
      }
    });
  }

  void abortProcessing() {
    _service.cancelProcessing();
  }
}
