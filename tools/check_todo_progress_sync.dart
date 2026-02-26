import 'dart:io';

final RegExp _checkboxPattern = RegExp(
  r'^\s*-\s\[(x|X| )\]\s',
  multiLine: true,
);
final RegExp _todoLinePattern = RegExp(
  r'^(- \[[ xX]\] .+?) \((?:진행중|대기|완료), \d+/\d+ 완료\) \(`(docs/todo/[^`]+)`\)$',
  multiLine: true,
);

const String kTodoDocPath = 'docs/TODO.md';

Future<void> main() async {
  final ProcessResult diffResult = await Process.run(
    'git',
    <String>['diff', '--name-only', '--cached'],
    runInShell: true,
  );

  if (diffResult.exitCode != 0) {
    stderr.writeln('todo-sync-check: staged 파일 조회 실패');
    stderr.writeln(diffResult.stderr.toString().trim());
    exit(diffResult.exitCode);
  }

  final List<String> stagedFiles = diffResult.stdout
      .toString()
      .split('\n')
      .map((String line) => line.trim().replaceAll('\\', '/'))
      .where((String line) => line.isNotEmpty)
      .toList();

  final bool todoRelatedChanged = stagedFiles.any(_isTodoRelatedChange);
  if (!todoRelatedChanged) {
    stdout.writeln('todo-sync-check: SKIP (TODO 관련 변경 없음)');
    return;
  }

  final File todoFile = File(kTodoDocPath);
  if (!todoFile.existsSync()) {
    stderr.writeln('todo-sync-check: `$kTodoDocPath` 파일을 찾을 수 없습니다.');
    exit(1);
  }

  final String content = todoFile.readAsStringSync();
  bool hasMismatch = false;

  for (final RegExpMatch match in _todoLinePattern.allMatches(content)) {
    final String prefix = match.group(1)!;
    final String detailPath = match.group(2)!;
    final File detailFile = File(detailPath);

    if (!detailFile.existsSync()) {
      stderr.writeln('todo-sync-check: 상세 TODO 파일이 없습니다: $detailPath');
      hasMismatch = true;
      continue;
    }

    final String detailContent = detailFile.readAsStringSync();
    final List<RegExpMatch> checks = _checkboxPattern
        .allMatches(detailContent)
        .toList();
    final int total = checks.length;
    final int done = checks
        .where((RegExpMatch m) => (m.group(1) ?? '').toLowerCase() == 'x')
        .length;
    final String status = _status(done: done, total: total);

    final String expectedLine = '$prefix ($status, $done/$total 완료) (`$detailPath`)';
    final String currentLine = match.group(0)!;
    if (currentLine != expectedLine) {
      stderr.writeln('todo-sync-check: 진행률 불일치 감지');
      stderr.writeln('- path: $detailPath');
      stderr.writeln('- 현재: $currentLine');
      stderr.writeln('- 기대: $expectedLine');
      hasMismatch = true;
    }
  }

  if (hasMismatch) {
    stderr.writeln('todo-sync-check: 조치 가이드 -> `make todo-sync` 실행');
    stderr.writeln('todo-sync-check: 동기화 결과를 스테이징한 뒤 다시 커밋해 주세요.');
    exit(1);
  }

  stdout.writeln('todo-sync-check: OK');
}

bool _isTodoRelatedChange(String path) {
  return path == kTodoDocPath || path.startsWith('docs/todo/');
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
