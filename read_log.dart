import 'dart:io';
import 'dart:convert';

void main() {
  final file = File('analyze.log');
  if (!file.existsSync()) {
    print('No analyze.log');
    return;
  }

  // read as bytes and decode with utf16 or fallback
  List<int> bytes = file.readAsBytesSync();
  String content = '';
  try {
    // Powershell Out-File typically uses UTF-16 LE
    content = utf8.decode(bytes);
  } catch (e) {
    try {
      content = String.fromCharCodes(bytes); // Fallback string conversion
      content = content.replaceAll('\x00', ''); // Remove null bytes for utf16le
    } catch (e) {
      print('Failed to parse: $e');
      return;
    }
  }

  final lines = content.split('\n');
  int errorCount = 0;
  for (var line in lines) {
    if (line.contains('error -') || line.contains('warning -')) {
      print(line.trim());
      errorCount++;
      if (errorCount > 30) break;
    }
  }
}
