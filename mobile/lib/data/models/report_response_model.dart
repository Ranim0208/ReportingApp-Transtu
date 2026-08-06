class StatusModel {
  final int statusId;
  final String code;
  final String label;

  const StatusModel({
    required this.statusId,
    required this.code,
    required this.label,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      statusId: json['statusId'] as int,
      code: json['code'] as String,
      label: json['label'] as String,
    );
  }
}

class ReportResponseModel {
  final int reportId;
  final String uuid;
  final String reference;
  final String creationDate;
  final String description;
  final String? priority;
  final String reportTypeCode;
  final String reportTypeLabel;
  final StatusModel status;

  // From nested transportSupport object
  final String supportLabel;
  final String supportTypeCode;
  final String supportTypeLabel;

  const ReportResponseModel({
    required this.reportId,
    required this.uuid,
    required this.reference,
    required this.creationDate,
    required this.description,
    this.priority,
    required this.reportTypeCode,
    required this.reportTypeLabel,
    required this.status,
    required this.supportLabel,
    required this.supportTypeCode,
    required this.supportTypeLabel,
  });

  factory ReportResponseModel.fromJson(Map<String, dynamic> json) {
    final support = json['transportSupport'] as Map<String, dynamic>? ?? {};
    final status = json['status'] as Map<String, dynamic>? ?? {};

    return ReportResponseModel(
      reportId: json['reportId'] as int,
      uuid: json['uuid'] as String,
      reference: json['reference'] as String,
      creationDate: json['creationDate'] as String,
      description: json['description'] as String,
      priority: json['priority'] as String?,
      reportTypeCode: json['reportTypeCode'] as String? ?? '',
      reportTypeLabel: json['reportTypeLabel'] as String? ?? '',
      status: StatusModel.fromJson(status),
      supportLabel: support['label'] as String? ?? '',
      supportTypeCode: support['supportTypeCode'] as String? ?? '',
      supportTypeLabel: support['supportTypeLabel'] as String? ?? '',
    );
  }
}
