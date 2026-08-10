class MyReportModel {
  final String  uuid;
  final String  reference;
  final String  creationDate;
  final String  description;
  final String? reportTypeLabel;
  final String? supportLabel;
  final String? statusCode;
  final String? statusLabel;

  const MyReportModel({
    required this.uuid,
    required this.reference,
    required this.creationDate,
    required this.description,
    this.reportTypeLabel,
    this.supportLabel,
    this.statusCode,
    this.statusLabel,
  });

  factory MyReportModel.fromJson(Map<String, dynamic> json) {
    return MyReportModel(
      uuid:            json['uuid']            as String,
      reference:       json['reference']       as String,
      creationDate:    json['creationDate']    as String,
      description:     json['description']     as String,
      reportTypeLabel: json['reportTypeLabel'] as String?,
      supportLabel:    json['supportLabel']    as String?,
      statusCode:      json['statusCode']      as String?,
      statusLabel:     json['statusLabel']     as String?,
    );
  }

  /// Convert to SharedPreferences format for consistency
  Map<String, dynamic> toRecentReport() => {
        'uuid':         uuid,
        'reference':    reference,
        'creationDate': creationDate,
        'statusCode':   statusCode ?? 'NEW',
      };
}