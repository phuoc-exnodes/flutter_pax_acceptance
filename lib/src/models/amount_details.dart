part of flutter_pax_acceptance;

class AmountDetails {
  final String currency;
  final String amount;
  final String? capturedAmount;
  final String? refundableAmount;

  ///Used with Sale request
  const AmountDetails.sale({
    required this.currency,
    required this.amount,
  })  : capturedAmount = null,
        refundableAmount = null;
  //
  const AmountDetails.refund({
    required this.currency,
    required this.amount,
  })  : capturedAmount = null,
        refundableAmount = null;

  const AmountDetails._response({
    required this.currency,
    required this.amount,
    required this.capturedAmount,
    required this.refundableAmount,
  });

  factory AmountDetails.fromJson(Map<String, dynamic> json) {
    return AmountDetails._response(
      currency: json['currency'] ?? '',
      amount: json['amount'] ?? '',
      capturedAmount: json['capturedAmount'],
      refundableAmount: json['refundableAmount'],
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'currency': currency,
      'amount': amount,
    };
    if (capturedAmount != null) {
      json.addAll({'capturedAmount': capturedAmount});
    }
    if (refundableAmount != null) {
      json.addAll({'refundableAmount': refundableAmount});
    }

    return json;
  }
}
