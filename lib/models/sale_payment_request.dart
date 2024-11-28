part of '../flutter_pax_acceptance.dart';

class SalePaymentRequest {
  final String type = 'PaymentRequest';
  final String merchantReferenceCode;
  final AmountDetails amountDetails;

  SalePaymentRequest({
    required this.merchantReferenceCode,
    required this.amountDetails,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'type': type,
      'merchantReferenceCode': merchantReferenceCode,
      'amountDetails': amountDetails.toJson(),
    };

    return json;
  }
}
