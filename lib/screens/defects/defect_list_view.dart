import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/defect_controller.dart';
import '../../models/defect_model.dart';
import 'defect_details_page.dart';
import 'report_defect_page.dart';

class DefectListView extends StatefulWidget {
  const DefectListView({Key? key}) : super(key: key);

  @override
  _DefectListViewState createState() => _DefectListViewState();
}

class _DefectListViewState extends State<DefectListView> {
  @override
  void initState() {
    super.initState();
    _loadUserDefects();
  }

  void _loadUserDefects() {
    final authController = Provider.of<AuthController>(context, listen: false);
    final defectController = Provider.of<DefectController>(
      context,
      listen: false,
    );

    if (authController.user != null) {
      defectController.loadUserDefects(authController.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defectController = Provider.of<DefectController>(context);
    final authController = Provider.of<AuthController>(context);

    if (authController.user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'You need to be logged in to view your reports',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      );
    }

    if (defectController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (defectController.userDefects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.report_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'You haven\'t reported any road defects yet',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportDefectPage()),
                );
              },
              child: const Text('Report a Defect'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Reports',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserDefects,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadUserDefects();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: defectController.userDefects.length,
          itemBuilder: (context, index) {
            final defect = defectController.userDefects[index];
            return _buildDefectCard(context, defect);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportDefectPage()),
          );
        },
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Report Defect'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 2,
      ),
    );
  }

  Widget _buildDefectCard(BuildContext context, DefectModel defect) {
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (defect.imageUrls.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Hero(
                  tag: 'defect-image-${defect.id}',
                  child: Image.network(
                    defect.imageUrls[0],
                    height: 180,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 180,
                        color: Colors.grey[100],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: Colors.grey[100],
                        child: const Center(
                          child: Icon(
                            Icons.error_outline,
                            size: 32,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            Container(
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPriorityIndicator(defect.priority),
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
                ],
              ),
            ),
          ],
        ),
      ),
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
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityIndicator(PriorityLevel priority) {
    String label;
    Color color;
    IconData icon;

    switch (priority) {
      case PriorityLevel.low:
        label = 'Low Priority';
        color = Colors.green;
        icon = Icons.keyboard_arrow_down;
        break;
      case PriorityLevel.medium:
        label = 'Medium Priority';
        color = Colors.orange;
        icon = Icons.remove;
        break;
      case PriorityLevel.high:
        label = 'High Priority';
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
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
