import 'package:flutter/material.dart';

class ReportFormScreen extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  const ReportFormScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Report Form')),
      );
}
