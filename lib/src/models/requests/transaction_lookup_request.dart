class TransactionLookupRequest {
  final String type;
  final String idType;
  final String id;

  ///Used with Sale request
  const TransactionLookupRequest.fromTransactID({
    required this.id,
  })  : type = 'TransactionLookupRequest',
        idType = 'TRANSACTION_ID';
  //
  const TransactionLookupRequest.fromMerchantRef({
    required this.id,
  })  : type = 'TransactionLookupRequest',
        idType = 'MERCHANT_REFERENCE_CODE';

  const TransactionLookupRequest._response({
    required this.type,
    required this.idType,
    required this.id,
  });

  factory TransactionLookupRequest.fromJson(Map<String, dynamic> json) {
    return TransactionLookupRequest._response(
      type: json['type'],
      idType: json['idType'] ?? '',
      id: json['id'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'type': type,
      'idType': idType,
      'id': id,
    };

    return json;
  }
}
