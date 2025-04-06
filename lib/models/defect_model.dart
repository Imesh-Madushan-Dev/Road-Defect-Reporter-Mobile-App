enum PriorityLevel { low, medium, high }

class DefectModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final String? address;
  final List<String> imageUrls;
  final String reportedBy;
  final DateTime timestamp;
  final String status;
  final PriorityLevel priority;

  DefectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.address,
    required this.imageUrls,
    required this.reportedBy,
    required this.timestamp,
    required this.status,
    required this.priority,
  });

  // Method to convert JSON to DefectModel
  factory DefectModel.fromJson(Map<String, dynamic> json) {
    return DefectModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      address: json['address'] as String?,
      imageUrls: (json['imageUrls'] as List).map((e) => e as String).toList(),
      reportedBy: json['reportedBy'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String,
      priority: PriorityLevel.values.byName(json['priority'] as String),
    );
  }

  // Method to convert DefectModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'address': address,
      'imageUrls': imageUrls,
      'reportedBy': reportedBy,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'priority': priority.name,
    };
  }
}
