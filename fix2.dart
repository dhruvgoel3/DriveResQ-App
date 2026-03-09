import 'dart:io';

void main() async {
  final file = File('lib/modules/jobs/services/invoice_generator.dart');
  if (!await file.exists()) return;
  var text = await file.readAsString();
  text = text.replaceAll('const pw.EdgeInsets', 'pw.EdgeInsets');
  text = text.replaceAll('const pw.TextStyle', 'pw.TextStyle');
  await file.writeAsString(text);
  print('Fixed invoice generator consts');
}
