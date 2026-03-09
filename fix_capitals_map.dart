import 'dart:io';

void main() {
  final targetDirs = [
    'd:/Complete Flutter/driveresq_app/lib/modules',
    'd:/Complete Flutter/driveresq_app/lib/shared',
    'd:/Complete Flutter/driveresq_app/lib/utils/widgets',
  ];

  final Map<String, String> corrections = {
    'honeNumberView': 'PhoneNumberView',
    'nboardingView': 'OnboardingView',
    'TPVerificationView': 'OTPVerificationView',
    'oleSelectionView': 'RoleSelectionView',
    'plashView': 'SplashView',
    'hatListView': 'ChatListView',
    'mptyStateWidget': 'EmptyStateWidget',
    'hatScreen': 'ChatScreen',
    'essageBubble': 'MessageBubble',
    'riceQuoteCard': 'PriceQuoteCard',
    'uickRepliesBar': 'QuickRepliesBar',
    'riverDashboardView': 'DriverDashboardView',
    'riverActiveRequestView': 'DriverActiveRequestView',
    'riverHomeView': 'DriverHomeView',
    'opupMenuItem': 'PopupMenuItem',
    'riverOnboardingView': 'DriverOnboardingView',
    'riverProfileView': 'DriverProfileView',
    'ctiveRequestCard': 'ActiveRequestCard',
    'arkerId': 'MarkerId',
    'nfoWindow': 'InfoWindow',
    'riverEmptyState': 'DriverEmptyState',
    'riverMapWidget': 'DriverMapWidget',
    'ameraPosition': 'CameraPosition',
    'atLng': 'LatLng',
    'afetyTipsSection': 'SafetyTipsSection',
    'obSummaryView': 'JobSummaryView',
    'aymentView': 'PaymentView',
    'atingView': 'RatingView',
    'ompletionSuccessView': 'CompletionSuccessView',
    'obCompletionPage': 'JobCompletionPage',
    'imeOfDay': 'TimeOfDay',
    'ctiveRequestDetailsPage': 'ActiveRequestDetailsPage',
    'urrentRequestView': 'CurrentRequestView',
    'cceptedRequestIndicatorCard': 'AcceptedRequestIndicatorCard',
    'echanicEmptyState': 'MechanicEmptyState',
    'echanicDashboardView': 'MechanicDashboardView',
    'tep': 'Step',
    'lwaysStoppedAnimation': 'AlwaysStoppedAnimation',
    'liderThemeData': 'SliderThemeData',
    'echanicProfileView': 'MechanicProfileView',
    'ivider': 'Divider',
    'erificationPendingView': 'VerificationPendingView',
    'echanicActiveJobCard': 'MechanicActiveJobCard',
    'otificationsView': 'NotificationsView',
    'otificationSettingsView': 'NotificationSettingsView',
    'ocationSettings': 'LocationSettings',
    'iveTrackingView': 'LiveTrackingView',
    'olylineId': 'PolylineId',
    'oundedRectangleBorder': 'RoundedRectangleBorder',
    'rrorStateWidget': 'ErrorStateWidget',
    'ounceButton': 'BounceButton',
    'taggeredListItem': 'StaggeredListItem',
    'ppTextField': 'AppTextField',
  };

  for (final targetDir in targetDirs) {
    final dir = Directory(targetDir);
    if (!dir.existsSync()) continue;

    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        String content = entity.readAsStringSync();
        String original = content;

        for (final entry in corrections.entries) {
          content = content.replaceAll(r'$1' + entry.key, entry.value);
        }

        if (content != original) {
          entity.writeAsStringSync(content);
          print('Fixed \${entity.path}');
        }
      }
    }
  }
}
