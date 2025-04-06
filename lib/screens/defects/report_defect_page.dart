import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/defect_controller.dart';
import '../../models/defect_model.dart';
import '../../utils/validators.dart';

class ReportDefectPage extends StatefulWidget {
  const ReportDefectPage({Key? key}) : super(key: key);

  @override
  _ReportDefectPageState createState() => _ReportDefectPageState();
}

class _ReportDefectPageState extends State<ReportDefectPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<File> _selectedImages = [];
  PriorityLevel _selectedPriority = PriorityLevel.medium;
  bool _hasLocationPermission = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
    final ImagePicker picker = ImagePicker();

    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(
          images.map((image) => File(image.path)).toList(),
        );
      });
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();

    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _selectedImages.add(File(photo.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Defect report submitted successfully')),
        );
      } else if (mounted && defectController.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(defectController.error!)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defectController = Provider.of<DefectController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Report Road Defect',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Location Permission Status
                        if (!_hasLocationPermission)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_off_outlined,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Location Permission Required',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'We need location access to accurately report the defect location.',
                                        style: TextStyle(
                                          color: Colors.orange.shade900,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: _requestLocationPermission,
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.orange.shade900,
                                  ),
                                  child: const Text('Enable'),
                                ),
                              ],
                            ),
                          ),
                        // Images section
                        Row(
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Photos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add photos of the defect (at least one required):',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _pickImages,
                                      icon: const Icon(
                                        Icons.photo_library_outlined,
                                      ),
                                      label: const Text('Gallery'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _takePhoto,
                                      icon: const Icon(
                                        Icons.camera_alt_outlined,
                                      ),
                                      label: const Text('Camera'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              if (_selectedImages.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Center(
                                    child: Text(
                                      'No photos selected',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                )
                              else ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 120,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _selectedImages.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.file(
                                                _selectedImages[index],
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap:
                                                    () => _removeImage(index),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Image count indicator
                                            Positioned(
                                              bottom: 4,
                                              left: 4,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  '${index + 1}/${_selectedImages.length}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Tip: Take clear photos from multiple angles',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                        // Form sections
                        Text(
                          'Defect Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title field
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            hintText: 'e.g. Pothole on Main Street',
                            prefixIcon: const Icon(Icons.title_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            helperText:
                                'Enter a clear, descriptive title for the defect',
                          ),
                          validator: (value) => Validators.validateTitle(value),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),

                        // Description field
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            hintText:
                                'Describe the defect in detail (size, severity, safety concerns, etc.)',
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 80),
                              child: Icon(Icons.description_outlined),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            alignLabelWithHint: true,
                            helperText:
                                'Be specific to help authorities assess the issue',
                          ),
                          validator:
                              (value) => Validators.validateDescription(value),
                        ),
                        const SizedBox(height: 24),

                        // Location section
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Current location will be captured automatically when submitting the report.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Priority selection
                        Text(
                          'Defect Priority',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select the level of urgency for this defect:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildPrioritySelector(),

                        const SizedBox(height: 24),

                        // Submit button
                        ElevatedButton(
                          onPressed:
                              defectController.isLoading ? null : _submitReport,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.6),
                          ),
                          child:
                              defectController.isLoading
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Text(
                                    'Submit Report',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
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
