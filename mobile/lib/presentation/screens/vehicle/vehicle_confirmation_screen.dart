import 'package:flutter/material.dart';

class VehicleConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  const VehicleConfirmationScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Vehicle Confirmation')),
      );
}
