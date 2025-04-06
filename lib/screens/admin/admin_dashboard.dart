import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/defect_model.dart';
import '../defects/defect_details_page.dart';
import '../../wrappers/route_guard.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap with RouteGuard to ensure only admins can access
    return RouteGuard(requireAdmin: true, child: AdminDashboardContent());
  }
}

class AdminDashboardContent extends StatefulWidget {
  const AdminDashboardContent({super.key});

  @override
  AdminDashboardContentState createState() => AdminDashboardContentState();
}

class AdminDashboardContentState extends State<AdminDashboardContent> {
  String? _statusFilter;
  PriorityLevel? _priorityFilter;

  @override
  Widget build(BuildContext context) {
    final adminController = Provider.of<AdminController>(context);
    Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => adminController.loadAllDefects(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter area
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.filter_list_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filters',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
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
                              }),
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
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            value: _priorityFilter,
                            items: [
                              const DropdownMenuItem<PriorityLevel?>(
                                value: null,
                                child: Text('All Priorities'),
                              ),
                              ...PriorityLevel.values.map((priority) {
                                String label;
                                Color color;
                                IconData icon;

                                switch (priority) {
                                  case PriorityLevel.low:
                                    label = 'Low';
                                    color = Colors.green;
                                    icon = Icons.keyboard_arrow_down;
                                    break;
                                  case PriorityLevel.medium:
                                    label = 'Medium';
                                    color = Colors.orange;
                                    icon = Icons.remove;
                                    break;
                                  case PriorityLevel.high:
                                    label = 'High';
                                    color = Colors.red;
                                    icon = Icons.keyboard_arrow_up;
                                    break;
                                }
                                return DropdownMenuItem<PriorityLevel?>(
                                  value: priority,
                                  child: Row(
                                    children: [
                                      Icon(icon, size: 16, color: color),
                                      const SizedBox(width: 8),
                                      Text(
                                        label,
                                        style: TextStyle(color: color),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() => _priorityFilter = value);
                              adminController.filterByPriority(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text('Clear Filters'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          backgroundColor: Colors.grey[100],
                          foregroundColor: Colors.grey[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _statusFilter = null;
                            _priorityFilter = null;
                          });
                          adminController.clearFilters();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Stats summary
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Reports',
                        adminController.allDefects.length.toString(),
                        Colors.blue,
                        Icons.insert_chart_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Pending',
                        adminController.allDefects
                            .where((d) => d.status.toLowerCase() == 'pending')
                            .length
                            .toString(),
                        Colors.orange,
                        Icons.pending_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Completed',
                        adminController.allDefects
                            .where((d) => d.status.toLowerCase() == 'completed')
                            .length
                            .toString(),
                        Colors.green,
                        Icons.check_circle_outline,
                      ),
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
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No defect reports match your filters',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _statusFilter = null;
                                    _priorityFilter = null;
                                  });
                                  adminController.clearFilters();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Clear Filters'),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: adminController.filteredDefects.length,
                          itemBuilder: (context, index) {
                            final defect =
                                adminController.filteredDefects[index];
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
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
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
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DefectDetailsPage(defectId: defect.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (defect.imageUrls.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Image.network(
                    defect.imageUrls[0],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[100],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder:
                        (_, __, ___) => Container(
                          height: 180,
                          color: Colors.grey[100],
                          child: const Center(
                            child: Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          defect.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(defect.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    defect.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPriorityChip(defect.priority),
                      Text(
                        DateFormat('MMM d, yyyy').format(defect.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey[200], thickness: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Reported by: ${defect.reportedBy}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (defect.status.toLowerCase() == 'pending' ||
                      defect.status.toLowerCase() == 'in progress')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (defect.status.toLowerCase() == 'pending')
                          Expanded(
                            child: _buildActionButton(
                              'Start Repair',
                              Icons.engineering_outlined,
                              Colors.blue,
                              () => _updateStatus(
                                context,
                                defect.id,
                                'In Progress',
                                adminController,
                              ),
                            ),
                          ),
                        if (defect.status.toLowerCase() == 'pending')
                          const SizedBox(width: 8),
                        if (defect.status.toLowerCase() == 'pending')
                          Expanded(
                            child: _buildActionButton(
                              'Reject',
                              Icons.cancel_outlined,
                              Colors.red,
                              () => _updateStatus(
                                context,
                                defect.id,
                                'Rejected',
                                adminController,
                              ),
                            ),
                          ),
                        if (defect.status.toLowerCase() == 'in progress')
                          Expanded(
                            child: _buildActionButton(
                              'Mark Completed',
                              Icons.check_circle_outline,
                              Colors.green,
                              () => _updateStatus(
                                context,
                                defect.id,
                                'Completed',
                                adminController,
                              ),
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
    IconData icon;

    switch (priority) {
      case PriorityLevel.low:
        label = 'Low';
        color = Colors.green;
        icon = Icons.keyboard_arrow_down;
        break;
      case PriorityLevel.medium:
        label = 'Medium';
        color = Colors.orange;
        icon = Icons.remove;
        break;
      case PriorityLevel.high:
        label = 'High';
        color = Colors.red;
        icon = Icons.keyboard_arrow_up;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending_outlined;
        break;
      case 'in progress':
        color = Colors.blue;
        icon = Icons.engineering_outlined;
        break;
      case 'completed':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel_outlined;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
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
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to $newStatus'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else if (mounted && adminController.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(adminController.error!),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
