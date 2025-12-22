import 'package:flutter/material.dart';
import '../../data/models/requisition.dart';
import '../../core/utils/formatters.dart';

/// Card widget to display requisition information in a list
class RequisitionCard extends StatelessWidget {
  final Requisition requisition;
  final VoidCallback? onTap;

  const RequisitionCard({
    super.key,
    required this.requisition,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with order number and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    requisition.orderNumber,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Date
              Text(
                'Date: ${requisition.date}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Brick type and quantity
              Row(
                children: [
                  Icon(
                    Icons.construction,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${requisition.brickType?.name ?? 'N/A'} - ${requisition.quantity} ${requisition.brickType?.unit ?? ''}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Customer name
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      requisition.customerName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Bottom row with total amount and arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Formatters.formatCurrency(double.tryParse(requisition.totalAmount) ?? 0),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String displayStatus;

    switch (requisition.status.toLowerCase()) {
      case 'submitted':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        displayStatus = 'Submitted';
        break;
      case 'assigned':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
        displayStatus = 'Assigned';
        break;
      case 'delivered':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        displayStatus = 'Delivered';
        break;
      case 'paid':
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade700;
        displayStatus = 'Paid';
        break;
      case 'complete':
        backgroundColor = Colors.teal.shade100;
        textColor = Colors.teal.shade700;
        displayStatus = 'Complete';
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        displayStatus = requisition.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }


}