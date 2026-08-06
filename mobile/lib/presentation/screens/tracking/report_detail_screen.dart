import 'package:flutter/material.dart';

class ReportDetailScreen extends StatelessWidget {
  final String uuid;
  const ReportDetailScreen({super.key, required this.uuid});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(child: Text('Detail: $uuid')),
      );
}
