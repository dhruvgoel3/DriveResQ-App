import 'dart:io';

void main() async {
  final outTxt = File('out_utf8.txt');
  if (!await outTxt.exists()) {
    print("out_utf8.txt not found");
    return;
  }

  final filesWithDups = <String>{};
  final lines = await outTxt.readAsLines();
  for (final line in lines) {
    if (line.contains('duplicate_constructor')) {
      final parts = line.split(' - ');
      if (parts.length >= 2) {
        final filePath = parts[2].split(':')[0].trim();
        filesWithDups.add(filePath);
      }
    }
  }

  for (final filePath in filesWithDups) {
    final file = File(filePath);
    if (!await file.exists()) continue;

    final fileLines = await file.readAsLines();
    final classNames = <String>[];

    for (final l in fileLines) {
      final m = RegExp(r'^\s*class\s+(\w+)\s+extends').firstMatch(l);
      if (m != null) {
        classNames.add(m.group(1)!);
      }
    }

    bool changed = false;
    for (final cls in classNames) {
      int idxConstEmpty = -1;
      int idxNonConstEmpty = -1;
      int idxOther = -1;

      for (int i = 0; i < fileLines.length; i++) {
        final stripped = fileLines[i].trim();
        if (stripped == "const $cls({super.key});") {
          idxConstEmpty = i;
        } else if (stripped == "$cls({super.key});") {
          idxNonConstEmpty = i;
        } else if (stripped.startsWith("$cls(") ||
            stripped.startsWith("const $cls(")) {
          if (stripped != "const $cls({super.key});" &&
              stripped != "$cls({super.key});") {
            idxOther = i;
          }
        }
      }

      if (idxConstEmpty != -1 && idxNonConstEmpty != -1) {
        fileLines[idxNonConstEmpty] = '///DELETE_ME///';
        changed = true;
      } else if (idxConstEmpty != -1 && idxOther != -1) {
        fileLines[idxConstEmpty] = '///DELETE_ME///';
        changed = true;
      } else if (idxNonConstEmpty != -1 && idxOther != -1) {
        fileLines[idxNonConstEmpty] = '///DELETE_ME///';
        changed = true;
      }
    }

    if (changed) {
      final newLines = fileLines.where((l) => l != '///DELETE_ME///').toList();
      await file.writeAsString(newLines.join('\n') + '\n');
      print("Fixed $filePath");
    }
  }
}
