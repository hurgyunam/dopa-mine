import 'package:flutter/material.dart';

import 'package:dopa_mine/models/exercise.dart';
import 'package:dopa_mine/models/workout_session.dart';
import 'package:dopa_mine/widgets/content_frame.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({
    super.key,
    required this.exercise,
    required this.session,
    required this.points,
  });

  final Exercise exercise;
  final WorkoutSession session;
  final int points;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.points} 포인트가 지급되었습니다.')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('리포트')),
      body: SafeArea(
        child: ContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '운동 완료!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text('종목: ${widget.exercise.name}'),
              Text('소요 시간: ${_formatDuration(widget.session.duration)}'),
              Text('수행 횟수: ${widget.session.repetitionCount}회'),
              Text('획득 포인트: +${widget.points}'),
              const Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).popUntil((Route<dynamic> route) {
                  return route.isFirst;
                });
              },
              child: const Text('홈으로'),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
