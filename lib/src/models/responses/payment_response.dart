import '../../../flutter_pax_acceptance.dart';

class PaymentResponse {
  final String type;
  final String? message;
  final TransactionDetails transactionDetails;

  PaymentResponse._({
    required this.type,
    required this.message,
    required this.transactionDetails,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse._(
      type: json['type'],
      message: json['message'],
      transactionDetails:
          TransactionDetails.fromJson(json['transactionDetails']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      'transactionDetails': transactionDetails.toJson(),
    };
  }
}
