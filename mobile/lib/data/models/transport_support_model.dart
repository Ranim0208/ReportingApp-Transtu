class TransportSupportModel {
  final int transportSupportId;
  final String uuid;
  final String reference;
  final String label;
  final String supportStatus;
  final String supportTypeCode;
  final String supportTypeLabel;

  const TransportSupportModel({
    required this.transportSupportId,
    required this.uuid,
    required this.reference,
    required this.label,
    required this.supportStatus,
    required this.supportTypeCode,
    required this.supportTypeLabel,
  });

  factory TransportSupportModel.fromJson(Map<String, dynamic> json) {
    return TransportSupportModel(
      transportSupportId: json['transportSupportId'] as int,
      uuid: json['uuid'] as String,
      reference: json['reference'] as String,
      label: json['label'] as String,
      // Backend sends enum name as String via Jackson
      supportStatus: json['supportStatus'] as String? ?? 'ACTIVE',
      supportTypeCode: json['supportTypeCode'] as String? ?? '',
      supportTypeLabel: json['supportTypeLabel'] as String? ?? '',
    );
  }
}
