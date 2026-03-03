class JobCompletionModel {
  final String jobId;
  final String driverId;
  final String mechanicId;
  final String driverPhone;
  final String mechanicPhone;
  final String driverName;
  final String mechanicName;
  final String shopName;
  final String vehicleType;
  final String problem;
  final String locationName;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final List<String> servicesPerformed;
  final List<Map<String, dynamic>> partsReplaced;
  final double laborCharges;
  final double travelCost;
  final double partsTotal;
  final double baseCharge;
  final double subtotal;
  final double gst;
  final double totalAmount;
  final String paymentMethod;
  final String? transactionId;
  final String notes;
  final double mechanicRating;
  final String? mechanicReview;
  final double driverRating;
  final String invoiceNumber;

  JobCompletionModel({
    required this.jobId,
    required this.driverId,
    required this.mechanicId,
    this.driverPhone = '',
    this.mechanicPhone = '',
    this.driverName = 'Driver',
    this.mechanicName = 'Mechanic',
    this.shopName = '',
    this.vehicleType = '',
    this.problem = '',
    this.locationName = '',
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.servicesPerformed,
    required this.partsReplaced,
    required this.laborCharges,
    required this.travelCost,
    required this.partsTotal,
    required this.baseCharge,
    required this.subtotal,
    required this.gst,
    required this.totalAmount,
    required this.paymentMethod,
    this.transactionId,
    this.notes = '',
    this.mechanicRating = 0,
    this.mechanicReview,
    this.driverRating = 0,
    required this.invoiceNumber,
  });

  Map<String, dynamic> toJson() => {
    'jobId': jobId,
    'driverId': driverId,
    'mechanicId': mechanicId,
    'driverPhone': driverPhone,
    'mechanicPhone': mechanicPhone,
    'driverName': driverName,
    'mechanicName': mechanicName,
    'shopName': shopName,
    'vehicleType': vehicleType,
    'problem': problem,
    'locationName': locationName,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'durationMinutes': duration.inMinutes,
    'servicesPerformed': servicesPerformed,
    'partsReplaced': partsReplaced,
    'laborCharges': laborCharges,
    'travelCost': travelCost,
    'partsTotal': partsTotal,
    'baseCharge': baseCharge,
    'subtotal': subtotal,
    'gst': gst,
    'totalAmount': totalAmount,
    'paymentMethod': paymentMethod,
    'transactionId': transactionId,
    'notes': notes,
    'mechanicRating': mechanicRating,
    'mechanicReview': mechanicReview,
    'driverRating': driverRating,
    'invoiceNumber': invoiceNumber,
  };
}
