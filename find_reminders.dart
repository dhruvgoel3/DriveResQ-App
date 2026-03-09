import 'dart:io';

void main() {
  final targetDirs = [
    'd:/Complete Flutter/driveresq_app/lib/modules',
    'd:/Complete Flutter/driveresq_app/lib/shared',
    'd:/Complete Flutter/driveresq_app/lib/utils/widgets',
  ];

  Set<String> uniqueReminders = {};

  for (final targetDir in targetDirs) {
    final dir = Directory(targetDir);
    if (!dir.existsSync()) continue;

    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        String content = entity.readAsStringSync();
        final matches = RegExp(r'\$1([a-zA-Z]+)').allMatches(content);
        for (final m in matches) {
          uniqueReminders.add(m.group(1)!);
        }
      }
    }
  }

  File('unique_reminders.txt').writeAsStringSync(uniqueReminders.join(', '));
  print('Done parsing');
}
