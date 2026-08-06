class ReplyEntity {
  final String message;
  final String replyDate;

  const ReplyEntity({
    required this.message,
    required this.replyDate,
  });
}

class TrackingResult {
  final String uuid;
  final String reference;
  final String creationDate;
  final String description;
  final String statusCode;
  final String statusLabel;
  final String? reportTypeLabel;
  final String? supportLabel;
  final List<ReplyEntity> replies;

  const TrackingResult({
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
}
