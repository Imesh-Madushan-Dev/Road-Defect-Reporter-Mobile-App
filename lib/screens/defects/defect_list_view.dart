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

class _DefectListViewState extends State<DefectListView>
    with SingleTickerProviderStateMixin {
  String? _sortOption = 'newest';
  String? _statusFilter;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserDefects();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  List<DefectModel> _getSortedAndFilteredDefects(List<DefectModel> defects) {
    // First apply filters
    List<DefectModel> filteredDefects = defects;

    if (_statusFilter != null) {
      filteredDefects =
          filteredDefects
              .where(
                (defect) =>
                    defect.status.toLowerCase() == _statusFilter!.toLowerCase(),
              )
              .toList();
    }

    // Then sort
    switch (_sortOption) {
      case 'newest':
        filteredDefects.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case 'oldest':
        filteredDefects.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case 'priority':
        filteredDefects.sort(
          (a, b) => b.priority.index.compareTo(a.priority.index),
        );
        break;
    }

    return filteredDefects;
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

    // Get filtered and sorted defects
    final defects = _getSortedAndFilteredDefects(defectController.userDefects);

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
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter reports',
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh reports',
            onPressed: _loadUserDefects,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: () async {
            _loadUserDefects();
          },
          child:
              defectController.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : defects.isEmpty
                  ? _buildEmptyState()
                  : Column(
                    children: [
                      _buildSortBar(),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: defects.length,
                          itemBuilder: (context, index) {
                            final defect = defects[index];
                            return _buildDefectCard(context, defect);
                          },
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _statusFilter != null ? Icons.filter_alt_off : Icons.report_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              _statusFilter != null
                  ? 'No $_statusFilter reports found'
                  : 'You haven\'t reported any road defects yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_statusFilter != null)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _statusFilter = null;
                  });
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportDefectPage()),
                  );
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Report a Defect'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[50],
      child: Row(
        children: [
          Text(
            'Sort by:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortChip('Newest', 'newest'),
                  const SizedBox(width: 8),
                  _buildSortChip('Oldest', 'oldest'),
                  const SizedBox(width: 8),
                  _buildSortChip('Priority', 'priority'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortOption == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      labelStyle: TextStyle(
        color:
            isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _sortOption = value;
          });
        }
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Reports',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildFilterChip('All', null, setModalState),
                        _buildFilterChip('Pending', 'pending', setModalState),
                        _buildFilterChip(
                          'In Progress',
                          'in progress',
                          setModalState,
                        ),
                        _buildFilterChip(
                          'Completed',
                          'completed',
                          setModalState,
                        ),
                        _buildFilterChip('Rejected', 'rejected', setModalState),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String? value,
    StateSetter setModalState,
  ) {
    final isSelected = _statusFilter == value;
    Color chipColor;

    switch (value?.toLowerCase()) {
      case 'pending':
        chipColor = Colors.orange;
        break;
      case 'in progress':
        chipColor = Colors.blue;
        break;
      case 'completed':
        chipColor = Colors.green;
        break;
      case 'rejected':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      checkmarkColor: value == null ? Colors.grey[700] : chipColor,
      selectedColor:
          value == null ? Colors.grey[200] : chipColor.withOpacity(0.1),
      labelStyle: TextStyle(
        color:
            isSelected
                ? (value == null ? Colors.grey[700] : chipColor)
                : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      onSelected: (selected) {
        setModalState(() {
          _statusFilter = selected ? value : null;
        });
      },
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
          ).then((_) => setState(() {})); // Refresh when coming back
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (defect.imageUrls.isNotEmpty)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Hero(
                      tag: 'defect-image-${defect.id}',
                      child: Image.network(
                        defect.imageUrls[0],
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 180,
                            color: Colors.grey[100],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
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
                  // Date indicator
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        DateFormat('MMM d, yyyy').format(defect.timestamp),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Status indicator
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _buildStatusChip(defect.status),
                  ),
                ],
              ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // If no image, show status and date at top
                  if (defect.imageUrls.isEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMM d, yyyy').format(defect.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        _buildStatusChip(defect.status),
                      ],
                    ),
                  if (defect.imageUrls.isEmpty) const SizedBox(height: 12),

                  Text(
                    defect.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                      // Location preview
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            defect.address != null && defect.address!.isNotEmpty
                                ? _truncateAddress(defect.address!)
                                : 'View location',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
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

  String _truncateAddress(String address) {
    if (address.length <= 20) return address;
    return '${address.substring(0, 20)}...';
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
