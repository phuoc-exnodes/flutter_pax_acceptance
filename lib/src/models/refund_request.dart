part of flutter_pax_acceptance;

class RefundRequest {
  final String type = 'LinkedRefundRequest';
  final String transactionId;
  final AmountDetails amountDetails;

  RefundRequest({
    required this.transactionId,
    required this.amountDetails,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'type': type,
      'transactionId': transactionId,
      'amountDetails': amountDetails.toJson(),
    };

    return json;
  }
}
