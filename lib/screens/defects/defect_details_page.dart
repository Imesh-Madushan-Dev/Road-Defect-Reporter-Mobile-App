import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../controllers/defect_controller.dart';
import '../../models/defect_model.dart';

class DefectDetailsPage extends StatelessWidget {
  final String defectId;

  const DefectDetailsPage({Key? key, required this.defectId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defectController = Provider.of<DefectController>(context);

    // Find the defect from either user's defects or all defects
    DefectModel? defect = _findDefect(defectController);

    if (defect == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Defect Details'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: Text('Defect not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Defect Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image gallery
            if (defect.imageUrls.isNotEmpty)
              Stack(
                children: [
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      itemCount: defect.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Hero(
                          tag: index == 0
                              ? 'defect-image-${defect.id}'
                              : 'defect-image-${defect.id}-$index',
                          child: CachedNetworkImage(
                            imageUrl: defect.imageUrls[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[100],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
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
                        );
                      },
                    ),
                  ),
                  // Status bar at the bottom of the image
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(defect.status),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(defect.status),
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  defect.status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                height: 200,
                color: Colors.grey[100],
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No images available',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildPriorityIndicator(defect.priority),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  _buildInfoSection(
                    'Description',
                    defect.description,
                    Icons.description_outlined,
                  ),
                  const SizedBox(height: 24),

                  // Location
                  _buildInfoSection(
                    'Location',
                    defect.address ?? 'Location coordinates: ${defect.location}',
                    Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 24),

                  // Report time
                  _buildInfoSection(
                    'Report Time',
                    'Reported on ${DateFormat('MMM d, yyyy').format(defect.timestamp)} at ${DateFormat('h:mm a').format(defect.timestamp)}',
                    Icons.access_time_outlined,
                  ),

                  const SizedBox(height: 32),

                  // Map button
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Map viewing would be implemented here'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('View on Map'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DefectModel? _findDefect(DefectController controller) {
    // First try to find in user defects
    for (final defect in controller.userDefects) {
      if (defect.id == defectId) return defect;
    }

    // Then try in all defects (if available)
    for (final defect in controller.defects) {
      if (defect.id == defectId) return defect;
    }

    return null;
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityIndicator(PriorityLevel priority) {
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
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
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending_outlined;
      case 'in progress':
        return Icons.engineering_outlined;
      case 'completed':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
