import 'package:flutter/material.dart';

class SafetyInstructionsPage extends StatelessWidget {
  const SafetyInstructionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Safety Instructions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.health_and_safety_outlined,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stay Safe While Reporting',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Follow these guidelines to ensure your safety while reporting road defects.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  // Personal Safety Section
                  _buildSection(
                    theme,
                    title: 'Personal Safety',
                    icon: Icons.person_outline,
                    items: [
                      'Wear bright or reflective clothing when reporting defects',
                      'Avoid reporting during low visibility conditions',
                      'Stay alert and aware of your surroundings',
                      'Don\'t put yourself in dangerous situations',
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Traffic Safety Section
                  _buildSection(
                    theme,
                    title: 'Traffic Safety',
                    icon: Icons.directions_car_outlined,
                    items: [
                      'Never stand in the middle of the road',
                      'Maintain a safe distance from moving vehicles',
                      'Use sidewalks or road shoulders when available',
                      'Follow local traffic rules and regulations',
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Photography Safety Section
                  _buildSection(
                    theme,
                    title: 'Photography Safety',
                    icon: Icons.camera_alt_outlined,
                    items: [
                      'Take photos from a safe distance',
                      'Don\'t block traffic while taking photos',
                      'Use zoom instead of getting too close to hazards',
                      'Avoid using flash photography that could distract drivers',
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Weather Considerations Section
                  _buildSection(
                    theme,
                    title: 'Weather Considerations',
                    icon: Icons.wb_sunny_outlined,
                    items: [
                      'Avoid reporting during severe weather conditions',
                      'Be extra cautious during wet or slippery conditions',
                      'Stay hydrated and protected from sun exposure',
                      'Consider visibility conditions before reporting',
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Emergency Contacts Section
                  _buildSection(
                    theme,
                    title: 'Emergency Contacts',
                    icon: Icons.emergency_outlined,
                    items: [
                      'Police Emergency: 119',
                      'Ambulance Service: 110',
                      'Fire & Rescue: 111',
                      'Road Development Authority: 1968',
                    ],
                    isEmergencySection: true,
                  ),
                  const SizedBox(height: 32),

                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Important Notice',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[900],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your safety is our top priority. If you encounter a severe road hazard that poses immediate danger, contact emergency services immediately rather than attempting to report it through the app.',
                          style: TextStyle(
                            color: Colors.orange[900],
                            height: 1.5,
                          ),
                        ),
                      ],
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

  Widget _buildSection(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required List<String> items,
    bool isEmergencySection = false,
  }) {
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isEmergencySection
                          ? Colors.red.shade50
                          : theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color:
                      isEmergencySection
                          ? Colors.red
                          : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color:
                        isEmergencySection
                            ? Colors.red
                            : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color:
                            isEmergencySection
                                ? Colors.red.shade700
                                : Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
