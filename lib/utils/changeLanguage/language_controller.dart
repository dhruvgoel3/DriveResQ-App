// import 'dart:ui';
//
// import 'package:get/get.dart';
//
// class LanguageController extends GetxController {
//   final _box = GetStorage();
//
//   @override
//   void onInit() {
//     super.onInit();
//     final langCode = _box.read('langCode') ?? 'en';
//     final countryCode = _box.read('countryCode') ?? 'US';
//
//     Get.updateLocale(Locale(langCode, countryCode));
//   }
//
//   void changeLanguage(String langCode, String countryCode) {
//     Get.updateLocale(Locale(langCode, countryCode));
//
//     _box.write('langCode', langCode);
//     _box.write('countryCode', countryCode);
//   }
// }
