import 'package:flutter/material.dart';

class ServiceList extends StatelessWidget {
  final List<String> services;

  const ServiceList({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('Services:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ...services.map((service) => ListTile(title: Text(service))),
      ],
    );
  }
}
