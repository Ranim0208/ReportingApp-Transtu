class Report {
  final int reportId;
  final String uuid;
  final String reference;
  final String creationDate;
  final String description;
  final String? priority;
  final String reportTypeCode;
  final String reportTypeLabel;
  final String statusCode;
  final String statusLabel;
  final String supportLabel;
  final String supportTypeCode;
  final String supportTypeLabel;

  const Report({
    required this.reportId,
    required this.uuid,
    required this.reference,
    required this.creationDate,
    required this.description,
    this.priority,
    required this.reportTypeCode,
    required this.reportTypeLabel,
    required this.statusCode,
    required this.statusLabel,
    required this.supportLabel,
    required this.supportTypeCode,
    required this.supportTypeLabel,
  });
}
