import 'dart:io';

const String kNavigationDocPath = 'docs/architecture/05_navigation_routes.md';
const List<String> kRouteRelatedPrefixes = <String>[
  'app_flutter/lib/screens/',
  'app_flutter/lib/navigation/',
];
const List<String> kRouteRelatedFiles = <String>[
  'app_flutter/lib/main.dart',
];

Future<void> main() async {
  final ProcessResult diffResult = await Process.run(
    'git',
    <String>['diff', '--name-only', '--cached'],
    runInShell: true,
  );

  if (diffResult.exitCode != 0) {
    stderr.writeln('navigation-route-check: staged 파일 조회 실패');
    stderr.writeln(diffResult.stderr.toString().trim());
    exit(diffResult.exitCode);
  }

  final List<String> stagedFiles = diffResult.stdout
      .toString()
      .split('\n')
      .map((String line) => line.trim().replaceAll('\\', '/'))
      .where((String line) => line.isNotEmpty)
      .toList();

  final bool routeCodeChanged = stagedFiles.any(_isRouteRelatedChange);
  final bool navigationDocChanged = stagedFiles.contains(kNavigationDocPath);

  if (routeCodeChanged && !navigationDocChanged) {
    stderr.writeln('navigation-route-check: 화면 이동 코드 변경이 감지되었습니다.');
    stderr.writeln(
      'navigation-route-check: `$kNavigationDocPath`를 함께 수정해 주세요.',
    );
    stderr.writeln(
      'navigation-route-check: 조치 가이드 -> 문서 수정 후 `git add $kNavigationDocPath`',
    );
    stderr.writeln('navigation-route-check: 스테이징 파일 목록');
    for (final String path in stagedFiles) {
      stderr.writeln('- $path');
    }
    exit(1);
  }

  stdout.writeln('navigation-route-check: OK');
}

bool _isRouteRelatedChange(String path) {
  if (kRouteRelatedFiles.contains(path)) {
    return true;
  }
  for (final String prefix in kRouteRelatedPrefixes) {
    if (path.startsWith(prefix)) {
      return true;
    }
  }
  return false;
}
