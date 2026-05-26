import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final Color accentColor;
  final Widget child;

  const InfoCard({
    super.key,
    required this.title,
    required this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1D3525).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const Pill({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 11, color: color),
      ),
    );
  }
}
