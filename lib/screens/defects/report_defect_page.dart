import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/defect_controller.dart';
import '../../models/defect_model.dart';
import '../../utils/validators.dart';

class ReportDefectPage extends StatefulWidget {
  const ReportDefectPage({super.key});

  @override
  ReportDefectPageState createState() => ReportDefectPageState();
}

class ReportDefectPageState extends State<ReportDefectPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<File> _selectedImages = [];
  PriorityLevel _selectedPriority = PriorityLevel.medium;
  bool _hasLocationPermission = false;
  bool _showFab = true;
  double _lastScrollPos = 0;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _setupScrollListener();
    _setupAnimations();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final currentPos = _scrollController.position.pixels;
      if ((currentPos - _lastScrollPos).abs() > 50) {
        setState(() {
          _showFab = _lastScrollPos > currentPos;
          _lastScrollPos = currentPos;
        });
      }
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.status;
    setState(() {
      _hasLocationPermission = status.isGranted;
    });
  }

  Future<bool> _requestLocationPermission() async {
    final status = await Permission.location.request();
    setState(() {
      _hasLocationPermission = status.isGranted;
    });

    if (!status.isGranted) {
      if (mounted) {
        _showPermissionDeniedDialog();
      }
      return false;
    }
    return true;
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
              'We need location permission to accurately report the defect location. '
              'Please enable location permission in your device settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(
            images.map((image) => File(image.path)).toList(),
          );
        });
        // Provide haptic feedback
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      _showErrorSnackBar('Could not access gallery');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        setState(() {
          _selectedImages.add(File(photo.path));
        });
        // Provide haptic feedback
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      _showErrorSnackBar('Could not access camera');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  void _submitReport() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one image')),
        );
        return;
      }

      if (!_hasLocationPermission) {
        final granted = await _requestLocationPermission();
        if (!granted) return;
      }

      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );
      final defectController = Provider.of<DefectController>(
        context,
        listen: false,
      );

      if (authController.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to report defects'),
          ),
        );
        return;
      }

      final success = await defectController.createDefectReport(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        images: _selectedImages,
        userId: authController.user!.uid,
        priority: _selectedPriority,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Defect report submitted successfully'),
            backgroundColor: Colors.green, // Set background color to green
          ),
        );
      } else if (mounted && defectController.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(defectController.error!),
            backgroundColor: Colors.redAccent, // Set background color to green
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defectController = Provider.of<DefectController>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Report Road Defect',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: SizedBox(),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child:
            defectController.isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Submitting your report...',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
                : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Location Permission Card
                          if (!_hasLocationPermission)
                            _buildLocationPermissionCard(),

                          // Progress Indicator
                          _buildProgressIndicator(),
                          const SizedBox(height: 24),

                          // Images Section
                          _buildImagesSection(),
                          const SizedBox(height: 32),

                          // Form Sections
                          _buildDefectInformationSection(),
                          const SizedBox(height: 32),

                          // Location Section
                          _buildLocationSection(),
                          const SizedBox(height: 32),

                          // Priority Section
                          _buildPrioritySection(),
                          const SizedBox(height: 32),

                          // Submit Button
                          _buildSubmitButton(defectController),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _showFab ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _showFab ? 1 : 0,
          child: FloatingActionButton.extended(
            onPressed: () => _submitReport(),
            icon: const Icon(Icons.send, color: Colors.white),
            label: const Text(
              'Submit Report',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    int completedSteps = 0;
    if (_selectedImages.isNotEmpty) completedSteps++;
    if (_titleController.text.isNotEmpty) completedSteps++;
    if (_descriptionController.text.isNotEmpty) completedSteps++;
    if (_hasLocationPermission) completedSteps++;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Report Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '${(completedSteps / 4 * 100).round()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: completedSteps / 4,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationPermissionCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange.shade50, Colors.orange.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade200.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.location_off_outlined,
              color: Colors.orange.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Access Needed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enable location services to accurately report the defect location',
                  style: TextStyle(color: Colors.orange.shade800, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _requestLocationPermission,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange.shade900,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.photo_library_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Photos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Take clear photos from multiple angles',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildImageButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onPressed: _pickImages,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildImageButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onPressed: _takePhoto,
                ),
              ),
            ],
          ),
          if (_selectedImages.isNotEmpty) ...[
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return _buildImagePreview(index);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon), const SizedBox(width: 8), Text(label)],
      ),
    );
  }

  Widget _buildImagePreview(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.file(
              _selectedImages[index],
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedImages.removeAt(index);
                  });
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${index + 1}/${_selectedImages.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefectInformationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Defect Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              hintText: 'e.g. Large pothole on Main Street',
              prefixIcon: const Icon(Icons.title_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (value) => Validators.validateTitle(value),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Describe the defect in detail...',
              alignLabelWithHint: true,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 80),
                child: Icon(Icons.description_outlined),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (value) => Validators.validateDescription(value),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Will be captured automatically',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.priority_high_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Priority Level',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Select the urgency level',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPrioritySelector(),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(DefectController defectController) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: defectController.isLoading ? 56 : 0,
      child:
          defectController.isLoading
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox(),
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      children:
          PriorityLevel.values.map((priority) {
            String label;
            String description;
            Color color;
            IconData icon;

            switch (priority) {
              case PriorityLevel.low:
                label = 'Low Priority';
                description = 'Minor issue, not an immediate safety concern';
                color = Colors.green;
                icon = Icons.keyboard_arrow_down;
                break;
              case PriorityLevel.medium:
                label = 'Medium Priority';
                description = 'Moderate issue that should be addressed soon';
                color = Colors.orange;
                icon = Icons.remove;
                break;
              case PriorityLevel.high:
                label = 'High Priority';
                description = 'Severe issue posing immediate safety risk';
                color = Colors.red;
                icon = Icons.keyboard_arrow_up;
                break;
            }

            return RadioListTile<PriorityLevel>(
              title: Row(
                children: [
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(fontWeight: FontWeight.w600, color: color),
                  ),
                ],
              ),
              subtitle: Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              value: priority,
              groupValue: _selectedPriority,
              activeColor: color,
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color:
                      _selectedPriority == priority ? color : Colors.grey[300]!,
                  width: _selectedPriority == priority ? 2 : 1,
                ),
              ),
              tileColor:
                  _selectedPriority == priority
                      ? color.withOpacity(0.05)
                      : null,
            );
          }).toList(),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text('Reporting Tips'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHelpItem(
                    'Title',
                    'Be clear and specific about the defect type',
                    Icons.title_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildHelpItem(
                    'Description',
                    'Include size, depth, and any safety concerns',
                    Icons.description_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildHelpItem(
                    'Photos',
                    'Take clear photos showing the defect and surrounding area',
                    Icons.photo_camera_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildHelpItem(
                    'Location',
                    'Make sure location permissions are enabled for accurate reporting',
                    Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildHelpItem(
                    'Priority',
                    'Set the appropriate urgency level based on safety risk',
                    Icons.priority_high_outlined,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
    );
  }

  Widget _buildHelpItem(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
