import 'dart:convert';

import '../flutter_pax_acceptance.dart';

///A capsulated flow for FlutterPaxAcceptance request.
///
///Passed in FlutterPaxAcceptance instance
class PayzliPaymentPAX {
  final FlutterPaxAcceptance _service;
  PayzliPaymentPAX(this._service);

  ///Check Service State before processing the request
  bool checkServiceState(void Function(String error)? onError) {
    if (_service.state != FlutterPaxAcceptance.connected) {
      onError?.call('FlutterPaxAcceptance not Connected');
      return false;
    }
    if (_service.state == FlutterPaxAcceptance.processing) {
      onError?.call('FlutterPaxAcceptance is processing a request');
      return false;
    }
    return true;
  }

  ///handle full payment flow
  ///return true if process has started, else:call onError and return false
  bool transactionSale(
    SalePaymentRequest request, {
    required void Function(PaymentResponse response) onDoneApproved,
    required void Function(PaymentResponse response) onDoneAborted,
    void Function(TransactionStatusResponse response)? onStatus,
    void Function(ErrorResponse response)? onErrorResponse,
    void Function(String error)? onError,
  }) {
    //Validating requirement,...
    if (!checkServiceState(onError)) {
      return false;
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
    return true;
  }

  ///handle Linkded Refund
  ///return true if process has started, else:call onError and return false
  bool refund(
    RefundRequest request, {
    required void Function(PaymentResponse response) onDoneApproved,
    required void Function(PaymentResponse response) onDoneAborted,
    void Function(TransactionStatusResponse response)? onStatus,
    void Function(ErrorResponse response)? onErrorResponse,
    void Function(String error)? onError,
  }) {
    //Validating requirement,...
    if (!checkServiceState(onError)) {
      return false;
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
    return true;
  }

  void abortProcessing() {
    _service.cancelProcessing();
  }

  ///handle Check Transaction Status
  ///return true if process has started, else:call onError and return false
  bool checkTransactionStatus(
    TransactionLookupRequest request, {
    required void Function(PaymentResponse response) onDone,
    void Function(TransactionStatusResponse response)? onMidStatus,
    void Function(ErrorResponse response)? onErrorResponse,
    void Function(String error)? onError,
  }) {
    //Check Service state,...
    if (!checkServiceState(onError)) {
      return false;
    }
    //validate input.,..

    //Start processing
    _service.process(request.toJson(), (data) {
      try {
        final jsonData = jsonDecode(data);

        switch (jsonData['type']) {
          case 'TransactionStatusResponse':
            {
              final response = TransactionStatusResponse.fromJson(jsonData);
              onMidStatus?.call(response);
            }
            break;
          case 'TransactionLookupResponse':
            {
              final paymentResponse = PaymentResponse.fromJson(jsonData);
              onDone.call(paymentResponse);
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
    return true;
  }
}
