import '../../flutter_pax_acceptance.dart';

class TransactionDetails {
  final String id;
  final String merchantReferenceCode;
  final DateTime submitTimeUtc;
  final bool captured;
  final AmountDetails amountDetails;

  const TransactionDetails({
    required this.id,
    required this.merchantReferenceCode,
    required this.submitTimeUtc,
    required this.captured,
    required this.amountDetails,
  });

  factory TransactionDetails.fromJson(Map<String, dynamic> json) {
    return TransactionDetails(
      id: json['id'],
      merchantReferenceCode: json['merchantReferenceCode'],
      submitTimeUtc: DateTime.parse(json['submitTimeUtc']),
      captured: json['captured'],
      amountDetails: AmountDetails.fromJson(json['amountDetails']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchantReferenceCode': merchantReferenceCode,
      'submitTimeUtc': submitTimeUtc.toUtc(),
      'captured': captured,
      'amountDetails': amountDetails.toJson(),
    };
  }
}
