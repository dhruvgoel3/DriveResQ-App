import 'package:get/get.dart';

class MechanicDashboardController extends GetxController {
  var selectedTab = 0.obs; // 0 = current job, 1 = all requests

  void changeTab(int index) {
    selectedTab.value = index;
  }

  // Later you can bind real Firestore data here
  var hasActiveJob = true.obs;

  Map<String, dynamic> activeJob = {
    'vehicle': 'Silver Honda Civic',
    'address': '124 Oak Ave, Los Angeles',
    'problem': 'Flat Tire',
    'eta': '8 mins',
  };
}
