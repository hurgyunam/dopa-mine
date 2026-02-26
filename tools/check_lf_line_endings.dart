import 'dart:io';

const List<String> kLineEndingCheckPrefixes = <String>['tools/', '.githooks/'];

Future<void> main() async {
  final ProcessResult diffResult = await Process.run('git', <String>[
    'diff',
    '--name-only',
    '--cached',
    '--diff-filter=ACMR',
  ], runInShell: true);

  if (diffResult.exitCode != 0) {
    stderr.writeln('lf-check: staged 파일 조회 실패');
    stderr.writeln(diffResult.stderr.toString().trim());
    exit(diffResult.exitCode);
  }

  final List<String> stagedFiles = diffResult.stdout
      .toString()
      .split('\n')
      .map((String line) => line.trim().replaceAll('\\', '/'))
      .where((String line) => line.isNotEmpty)
      .toList();

  final List<String> targets = stagedFiles
      .where((String path) => kLineEndingCheckPrefixes.any(path.startsWith))
      .toList();

  if (targets.isEmpty) {
    stdout.writeln('lf-check: SKIP (검사 대상 변경 없음)');
    return;
  }

  final List<String> crlfFiles = <String>[];
  for (final String path in targets) {
    final List<int> bytes = await _readStagedFileBytes(path);
    if (_hasCrlf(bytes)) {
      crlfFiles.add(path);
    }
  }

  if (crlfFiles.isNotEmpty) {
    stderr.writeln('lf-check: CRLF 줄바꿈이 감지되었습니다.');
    stderr.writeln('lf-check: 아래 파일을 LF로 변환한 뒤 다시 스테이징해 주세요.');
    for (final String path in crlfFiles) {
      stderr.writeln('- $path');
    }
    stderr.writeln('lf-check: 예시) git add --renormalize <file>');
    exit(1);
  }

  stdout.writeln('lf-check: OK');
}

bool _hasCrlf(List<int> bytes) {
  for (int i = 0; i < bytes.length - 1; i++) {
    if (bytes[i] == 13 && bytes[i + 1] == 10) {
      return true;
    }
  }
  return false;
}

Future<List<int>> _readStagedFileBytes(String path) async {
  final ProcessResult showResult = await Process.run(
    'git',
    <String>['show', ':$path'],
    runInShell: true,
    stdoutEncoding: null,
    stderrEncoding: null,
  );

  if (showResult.exitCode != 0) {
    stderr.writeln('lf-check: 스테이징 파일 읽기 실패: $path');
    final Object? stderrData = showResult.stderr;
    if (stderrData is List<int>) {
      stderr.writeln(String.fromCharCodes(stderrData).trim());
    } else {
      stderr.writeln(showResult.stderr.toString().trim());
    }
    exit(showResult.exitCode);
  }

  final Object? stdoutData = showResult.stdout;
  if (stdoutData is List<int>) {
    return stdoutData;
  }
  return stdoutData.toString().codeUnits;
}
