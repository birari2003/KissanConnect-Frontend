import 'package:flutter/material.dart';

class RequestStatusWidget extends StatelessWidget {
  const RequestStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock status - replace with actual API call
    final status = 'approved'; // Can be: 'pending', 'approved', 'rejected'

    return Container(
      color: Color(0xFFF5F7FA),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusCard(status),
              SizedBox(height: 32),
              _buildStatusInfo(status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    IconData icon;
    Color color;
    String title;
    String subtitle;

    switch (status) {
      case 'pending':
        icon = Icons.hourglass_empty;
        color = Color(0xFFF4B23B);
        title = 'Request Pending';
        subtitle = 'Your super admin request is under review';
        break;
      case 'approved':
        icon = Icons.check_circle;
        color = Color(0xFF7BB53B);
        title = 'Request Approved';
        subtitle = 'Congratulations! You are now a Super Admin';
        break;
      case 'rejected':
        icon = Icons.cancel;
        color = Colors.red;
        title = 'Request Rejected';
        subtitle = 'Your request was not approved at this time';
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
        title = 'No Request';
        subtitle = 'You have not submitted a request yet';
    }

    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 60, color: color),
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A6E9B),
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo(String status) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF2A6E9B), size: 20),
              SizedBox(width: 8),
              Text(
                'Request Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A6E9B),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildInfoRow('Status', _getStatusText(status)),
          SizedBox(height: 12),
          _buildInfoRow('Submitted', '15 Sep 2025'),
          SizedBox(height: 12),
          _buildInfoRow('Region', 'Maharashtra > Pune > Kothrud'),
          if (status == 'pending') ...[
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF4B23B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFF4B23B).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: Color(0xFFF4B23B), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your request is being reviewed by the admin. You will be notified once a decision is made.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (status == 'approved') ...[
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF7BB53B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFF7BB53B).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.celebration, color: Color(0xFF7BB53B), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You now have super admin privileges. You can manage farmers and send messages in your assigned region.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2A6E9B),
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending Review';
      case 'approved':
        return 'Approved ✓';
      case 'rejected':
        return 'Rejected ✗';
      default:
        return 'Unknown';
    }
  }
}
