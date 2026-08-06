class ReplyModel {
  final String message;
  final String replyDate;

  const ReplyModel({
    required this.message,
    required this.replyDate,
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      message: json['message'] as String,
      replyDate: json['replyDate'] as String,
    );
  }
}

class TrackingResponseModel {
  final String uuid;
  final String reference;
  final String creationDate;
  final String description;
  final String statusCode;
  final String statusLabel;
  final String? reportTypeLabel;
  final String? supportLabel;
  final List<ReplyModel> replies;

  const TrackingResponseModel({
    required this.uuid,
    required this.reference,
    required this.creationDate,
    required this.description,
    required this.statusCode,
    required this.statusLabel,
    this.reportTypeLabel,
    this.supportLabel,
    required this.replies,
  });

  factory TrackingResponseModel.fromJson(Map<String, dynamic> json) {
    final repliesJson = json['replies'] as List<dynamic>? ?? [];
    return TrackingResponseModel(
      uuid: json['uuid'] as String,
      reference: json['reference'] as String,
      creationDate: json['creationDate'] as String,
      description: json['description'] as String,
      statusCode: json['statusCode'] as String,
      statusLabel: json['statusLabel'] as String,
      reportTypeLabel: json['reportTypeLabel'] as String?,
      supportLabel: json['supportLabel'] as String?,
      replies: repliesJson
          .map((r) => ReplyModel.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}
