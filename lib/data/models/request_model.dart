class RequestModel {
  final String driverId;
  final String locationName;
  final String landmark;
  final String vehicleType;
  final String problem;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;

  RequestModel({
    required this.driverId,
    required this.locationName,
    required this.landmark,
    required this.vehicleType,
    required this.problem,
    this.description,
    this.imageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'locationName': locationName,
      'landmark': landmark,
      'vehicleType': vehicleType,
      'problem': problem,
      'description': description,
      'imageUrl': imageUrl,
      'status': 'open',
      'createdAt': createdAt,
    };
  }
}
