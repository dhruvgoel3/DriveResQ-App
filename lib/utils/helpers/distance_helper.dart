import 'dart:math';

class DistanceHelper {
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {

    const R = 6371; // Earth radius KM
    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);

    double a =
        sin(dLat/2) * sin(dLat/2) +
            cos(_deg2rad(lat1)) *
                cos(_deg2rad(lat2)) *
                sin(dLon/2) *
                sin(dLon/2);

    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    return R * c;
  }

  static double _deg2rad(double deg) => deg * (pi / 180);
}
