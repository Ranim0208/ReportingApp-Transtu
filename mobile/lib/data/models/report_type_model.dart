class ReportTypeModel {
  final int reportTypeId;
  final String code;
  final String label;
  final String? description;
  final bool active;

  const ReportTypeModel({
    required this.reportTypeId,
    required this.code,
    required this.label,
    this.description,
    required this.active,
  });

  factory ReportTypeModel.fromJson(Map<String, dynamic> json) {
    return ReportTypeModel(
      reportTypeId: json['reportTypeId'] as int,
      code: json['code'] as String,
      label: json['label'] as String,
      description: json['description'] as String?,
      active: json['active'] as bool,
    );
  }
}
