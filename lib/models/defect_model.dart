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
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      address: json['address'],
      imageUrls: List<String>.from(json['imageUrls']),
      reportedBy: json['reportedBy'],
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'],
      priority: PriorityLevel.values.byName(json['priority']),
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
