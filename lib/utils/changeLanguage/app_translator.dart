import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'driver_profile': 'Driver Profile',
      'logout': 'Logout',
      'language': 'Language',
      'notifications': 'Notifications',
      'profile_completion': 'Profile Completion',
      'basic_information': 'Basic Information',
      'safety_trust': 'Safety & Trust',
      'verified_driver': 'VERIFIED DRIVER',
    },
    'hi_IN': {
      'driver_profile': 'ड्राइवर प्रोफ़ाइल',
      'logout': 'लॉग आउट',
      'language': 'भाषा',
      'notifications': 'सूचनाएं',
      'profile_completion': 'प्रोफ़ाइल पूर्णता',
      'basic_information': 'मूल जानकारी',
      'safety_trust': 'सुरक्षा और विश्वास',
      'verified_driver': 'सत्यापित ड्राइवर',
    },
  };
}
