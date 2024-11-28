class ErrorResponse {
  final String? type;
  final String? message;
  final String? developerDescription;

  ErrorResponse({
    required this.type,
    required this.message,
    required this.developerDescription,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      type: json['type'],
      message: json['message'],
      developerDescription: json['developerDescription'],
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'message': message,
        'developerDescription': developerDescription,
      };
}
