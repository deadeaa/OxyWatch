import 'package:flutter/material.dart';
import '../services/ai_scoring_service.dart';

class VitalCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String status;
  final Color statusColor;
  final IconData icon;
  final String? statusDetail;

  const VitalCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.status,
    required this.statusColor,
    required this.icon,
    this.statusDetail,
  });

  factory VitalCard.fromPrediction({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required String status,
    required String statusDetail,
  }) {
    Color statusColor;
    switch (status) {
      case 'bahaya':
        statusColor = Colors.red;
        break;
      case 'waspada':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.green;
    }

    return VitalCard(
      title: title,
      value: value,
      unit: unit,
      status: status,
      statusColor: statusColor,
      icon: icon,
      statusDetail: statusDetail,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2D9CDB), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (statusDetail != null) ...[
            const SizedBox(height: 4),
            Text(
              statusDetail!,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}