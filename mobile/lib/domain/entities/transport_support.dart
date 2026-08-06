class TransportSupport {
  final int transportSupportId;
  final String uuid;
  final String reference;
  final String label;
  final String supportStatus;
  final String supportTypeCode;
  final String supportTypeLabel;

  const TransportSupport({
    required this.transportSupportId,
    required this.uuid,
    required this.reference,
    required this.label,
    required this.supportStatus,
    required this.supportTypeCode,
    required this.supportTypeLabel,
  });
}
