import 'dart:io';

const String kProjectStateDocPath = 'docs/context/01_project_state.md';

// Changes in these paths likely affect current implementation status.
const List<String> kProjectStateTriggerPrefixes = <String>[
  'app_flutter/',
  'docs/todo/',
  '.cursor/rules/',
];

Future<void> main() async {
  final ProcessResult diffResult = await Process.run(
    'git',
    <String>['diff', '--name-only', '--cached'],
    runInShell: true,
  );

  if (diffResult.exitCode != 0) {
    stderr.writeln('project-state-check: staged 파일 조회 실패');
    stderr.writeln(diffResult.stderr.toString().trim());
    exit(diffResult.exitCode);
  }

  final List<String> stagedFiles = diffResult.stdout
      .toString()
      .split('\n')
      .map((String line) => line.trim().replaceAll('\\', '/'))
      .where((String line) => line.isNotEmpty)
      .toList();

  final bool triggerChanged = stagedFiles.any(_isProjectStateTriggerChange);
  final bool projectStateDocChanged = stagedFiles.contains(kProjectStateDocPath);

  if (triggerChanged && !projectStateDocChanged) {
    stderr.writeln('project-state-check: 구현/규칙 관련 변경이 감지되었습니다.');
    stderr.writeln(
      'project-state-check: `$kProjectStateDocPath`를 함께 수정해 주세요.',
    );
    stderr.writeln(
      'project-state-check: 조치 가이드 -> 문서 수정 후 `git add $kProjectStateDocPath`',
    );
    stderr.writeln('project-state-check: 스테이징 파일 목록');
    for (final String path in stagedFiles) {
      stderr.writeln('- $path');
    }
    exit(1);
  }

  stdout.writeln('project-state-check: OK');
}

bool _isProjectStateTriggerChange(String path) {
  for (final String prefix in kProjectStateTriggerPrefixes) {
    if (path.startsWith(prefix)) {
      return true;
    }
  }
  return false;
}
