.PHONY: nav-check state-check todo-check todo-sync

nav-check:
	dart run tools/check_navigation_routes_sync.dart

state-check:
	dart run tools/check_project_state_sync.dart

todo-check:
	dart run tools/check_todo_progress_sync.dart

todo-sync:
	dart run tools/sync_docs_todo_progress.dart
