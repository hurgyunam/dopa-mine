import 'dart:io';

final _checkboxPattern = RegExp(r'^\s*-\s\[(x|X| )\]\s', multiLine: true);
final _todoLinePattern = RegExp(
  r'^(- \[[ xX]\] .+?) \((?:진행중|대기|완료), \d+/\d+ 완료\) \(`(docs/todo/[^`]+)`\)$',
  multiLine: true,
);

void main() {
  final root = Directory.current.path;
  final todoFile = File('docs/TODO.md');

  if (!todoFile.existsSync()) {
    stderr.writeln('docs/TODO.md 파일을 찾을 수 없습니다. cwd=$root');
    exit(1);
  }

  var content = todoFile.readAsStringSync();
  var updated = 0;

  content = content.replaceAllMapped(_todoLinePattern, (match) {
    final prefix = match.group(1)!;
    final detailPath = match.group(2)!;
    final detailFile = File(detailPath);

    if (!detailFile.existsSync()) {
      stderr.writeln('상세 TODO 파일이 없어 건너뜁니다: $detailPath');
      return match.group(0)!;
    }

    final detailContent = detailFile.readAsStringSync();
    final matches = _checkboxPattern.allMatches(detailContent).toList();
    final total = matches.length;
    final done = matches
        .where((m) => (m.group(1) ?? '').toLowerCase() == 'x')
        .length;

    final status = _status(done: done, total: total);
    updated += 1;
    return '$prefix ($status, $done/$total 완료) (`$detailPath`)';
  });

  todoFile.writeAsStringSync(content);
  stdout.writeln('TODO 진행률 동기화 완료: $updated개 항목 업데이트');
}

String _status({required int done, required int total}) {
  if (total == 0 || done == 0) {
    return '대기';
  }
  if (done >= total) {
    return '완료';
  }
  return '진행중';
}
