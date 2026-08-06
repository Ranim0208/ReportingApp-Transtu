class ReportType {
  final int reportTypeId;
  final String code;
  final String label;
  final String? description;
  final bool active;

  const ReportType({
    required this.reportTypeId,
    required this.code,
    required this.label,
    this.description,
    required this.active,
  });
}
