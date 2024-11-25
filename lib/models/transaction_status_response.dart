class TransactionStatusResponse {
  final String type;
  final String message;

  TransactionStatusResponse({
    required this.type,
    required this.message,
  });

  factory TransactionStatusResponse.fromJson(Map<String, dynamic> json) {
    return TransactionStatusResponse(
      type: json['type'],
      message: json['message'],
    );
  }
}
