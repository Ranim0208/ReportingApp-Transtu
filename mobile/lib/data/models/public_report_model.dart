class PublicReportModel {
  final String  uuid;
  final String  reference;
  final String  creationDate;
  final String? publishDate;
  final String  description;
  final String? reportTypeLabel;
  final String? supportLabel;
  final String? supportTypeCode;
  final String? statusCode;
  final String? statusLabel;

  const PublicReportModel({
    required this.uuid,
    required this.reference,
    required this.creationDate,
    this.publishDate,
    required this.description,
    this.reportTypeLabel,
    this.supportLabel,
    this.supportTypeCode,
    this.statusCode,
    this.statusLabel,
  });

  factory PublicReportModel.fromJson(Map<String, dynamic> json) {
    return PublicReportModel(
      uuid:            json['uuid']            as String,
      reference:       json['reference']       as String,
      creationDate:    json['creationDate']    as String,
      publishDate:     json['publishDate']     as String?,
      description:     json['description']     as String,
      reportTypeLabel: json['reportTypeLabel'] as String?,
      supportLabel:    json['supportLabel']    as String?,
      supportTypeCode: json['supportTypeCode'] as String?,
      statusCode:      json['statusCode']      as String?,
      statusLabel:     json['statusLabel']     as String?,
    );
  }
}