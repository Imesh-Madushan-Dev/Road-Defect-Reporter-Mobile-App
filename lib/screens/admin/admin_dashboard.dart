import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/defect_model.dart';
import '../defects/defect_details_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String? _statusFilter;
  PriorityLevel? _priorityFilter;

  @override
  Widget build(BuildContext context) {
    final adminController = Provider.of<AdminController>(context);
    final authController = Provider.of<AuthController>(context);

    // Only allow admin access
    if (!authController.userData?['isAdmin'] == true) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
          child: Text('You do not have admin privileges to access this page.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => adminController.loadAllDefects(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter area
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        value: _statusFilter,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Statuses'),
                          ),
                          ...[
                            'Pending',
                            'In Progress',
                            'Completed',
                            'Rejected',
                          ].map((status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() => _statusFilter = value);
                          adminController.filterByStatus(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<PriorityLevel?>(
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        value: _priorityFilter,
                        items: [
                          const DropdownMenuItem<PriorityLevel?>(
                            value: null,
                            child: Text('All Priorities'),
                          ),
                          ...PriorityLevel.values.map((priority) {
                            String label;
                            switch (priority) {
                              case PriorityLevel.low:
                                label = 'Low';
                                break;
                              case PriorityLevel.medium:
                                label = 'Medium';
                                break;
                              case PriorityLevel.high:
                                label = 'High';
                                break;
                            }
                            return DropdownMenuItem<PriorityLevel?>(
                              value: priority,
                              child: Text(label),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() => _priorityFilter = value);
                          adminController.filterByPriority(value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Filters'),
                  onPressed: () {
                    setState(() {
                      _statusFilter = null;
                      _priorityFilter = null;
                    });
                    adminController.clearFilters();
                  },
                ),
              ],
            ),
          ),

          // Stats summary
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Total',
                  adminController.allDefects.length.toString(),
                  Colors.blue,
                  Icons.bar_chart,
                ),
                _buildStatCard(
                  'Pending',
                  adminController.allDefects
                      .where((d) => d.status.toLowerCase() == 'pending')
                      .length
                      .toString(),
                  Colors.orange,
                  Icons.hourglass_empty,
                ),
                _buildStatCard(
                  'Completed',
                  adminController.allDefects
                      .where((d) => d.status.toLowerCase() == 'completed')
                      .length
                      .toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
              ],
            ),
          ),

          // Defects list
          Expanded(
            child:
                adminController.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : adminController.filteredDefects.isEmpty
                    ? const Center(
                      child: Text('No defect reports match your filters'),
                    )
                    : ListView.builder(
                      itemCount: adminController.filteredDefects.length,
                      itemBuilder: (context, index) {
                        final defect = adminController.filteredDefects[index];
                        return _buildDefectCard(
                          context,
                          defect,
                          adminController,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(color: color.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildDefectCard(
    BuildContext context,
    DefectModel defect,
    AdminController adminController,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DefectDetailsPage(defectId: defect.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (defect.imageUrls.isNotEmpty)
              SizedBox(
                height: 120,
                width: double.infinity,
                child: Image.network(
                  defect.imageUrls[0],
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) =>
                          const Center(child: Icon(Icons.error, size: 32)),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          defect.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildPriorityChip(defect.priority),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    defect.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMM d, yyyy').format(defect.timestamp),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      _buildStatusChip(defect.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (defect.status.toLowerCase() == 'pending')
                        _buildActionButton(
                          'Start Repair',
                          Icons.build,
                          Colors.blue,
                          () => _updateStatus(
                            context,
                            defect.id,
                            'In Progress',
                            adminController,
                          ),
                        ),
                      if (defect.status.toLowerCase() == 'in progress')
                        _buildActionButton(
                          'Mark Completed',
                          Icons.check_circle,
                          Colors.green,
                          () => _updateStatus(
                            context,
                            defect.id,
                            'Completed',
                            adminController,
                          ),
                        ),
                      if (defect.status.toLowerCase() == 'pending')
                        _buildActionButton(
                          'Reject',
                          Icons.close,
                          Colors.red,
                          () => _updateStatus(
                            context,
                            defect.id,
                            'Rejected',
                            adminController,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(PriorityLevel priority) {
    String label;
    Color color;

    switch (priority) {
      case PriorityLevel.low:
        label = 'Low';
        color = Colors.green;
        break;
      case PriorityLevel.medium:
        label = 'Medium';
        color = Colors.orange;
        break;
      case PriorityLevel.high:
        label = 'High';
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'in progress':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return OutlinedButton.icon(
      icon: Icon(icon, color: color, size: 16),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(side: BorderSide(color: color)),
      onPressed: onPressed,
    );
  }

  void _updateStatus(
    BuildContext context,
    String defectId,
    String newStatus,
    AdminController adminController,
  ) async {
    final success = await adminController.updateDefectStatus(
      defectId,
      newStatus,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Status updated to $newStatus')));
    } else if (mounted && adminController.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(adminController.error!)));
    }
  }
}
