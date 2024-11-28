part of '../flutter_pax_acceptance.dart';

class PaxPairRequest {
  final String posId;
  final String setupCode;
  PaxPairRequest({
    required this.posId,
    required this.setupCode,
  });

  Map<String, dynamic> toJson() {
    return {"posId": posId, "setupCode": setupCode};
  }
}
