import 'dart:convert';

import '../flutter_pax_acceptance.dart';

///A capsulated flow for FlutterPaxAcceptance request.
///
///Passed in FlutterPaxAcceptance instance
class PayzliPaymentPAX {
  final FlutterPaxAcceptance _service;
  PayzliPaymentPAX(this._service);

  ///handle full payment flow
  void transactionSale(
    SalePaymentRequest request, {
    required void Function(PaymentResponse response) onDoneApproved,
    required void Function(PaymentResponse response) onDoneAborted,
    void Function(TransactionStatusResponse response)? onStatus,
    void Function(ErrorResponse response)? onErrorResponse,
    void Function(String error)? onError,
  }) {
    //Validating requirement,...
    if (_service.state != FlutterPaxAcceptance.connected) {
      onError?.call('FlutterPaxAcceptance not Connected');
      return;
    }
    if (_service.state == FlutterPaxAcceptance.processing) {
      onError?.call('FlutterPaxAcceptance is processing a request');
      return;
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
        _service.completeProcessing();
        onError?.call(e.toString());
      }
    });
    return;
  }

  ///handle Linkded Refund
  void refund(
    RefundRequest request, {
    required void Function(PaymentResponse response) onDoneApproved,
    required void Function(PaymentResponse response) onDoneAborted,
    void Function(TransactionStatusResponse response)? onStatus,
    void Function(ErrorResponse response)? onErrorResponse,
    void Function(String error)? onError,
  }) {
    //Validating requirement,...
    if (_service.state != FlutterPaxAcceptance.connected) {
      onError?.call('FlutterPaxAcceptance not Connected');
      return;
    }
    if (_service.state == FlutterPaxAcceptance.processing) {
      onError?.call('FlutterPaxAcceptance is processing a request');
      return;
    }
    //validate input

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
