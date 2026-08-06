import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  final Map<String, dynamic> report;
  const SuccessScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Success')),
      );
}
