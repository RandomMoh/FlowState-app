import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/stats/data/stats_provider.dart';
import '../features/tasks/data/tasks_provider.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(ref);
});

class ExportService {
  final Ref _ref;
  ExportService(this._ref);

  Future<void> exportDataToCsv() async {
    final tasks = _ref.read(tasksProvider);
    final sessions = _ref.read(statsProvider);

    List<List<dynamic>> rows = [];
    
    // Add Tasks Header
    rows.add(['--- TASKS ---']);
    rows.add(['ID', 'Title', 'Project', 'Tags', 'Completed', 'CompletedAt']);
    for (var t in tasks) {
      rows.add([
        t.id,
        t.title,
        t.project,
        t.tags.join(';'),
        t.isCompleted,
        t.completedAt?.toIso8601String() ?? '',
      ]);
    }

    rows.add([]); // Empty row
    
    // Add Sessions Header
    rows.add(['--- FOCUS SESSIONS ---']);
    rows.add(['Date', 'Duration (Minutes)']);
    for (var s in sessions) {
      rows.add([s.date.toIso8601String(), s.durationMinutes]);
    }

    String csvData = Csv().encode(rows);

    final downloadsDir = Directory('/storage/emulated/0/Download');
    if (!downloadsDir.existsSync()) {
      downloadsDir.createSync(recursive: true);
    }
    
    final file = File('${downloadsDir.path}/FlowState_Data_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvData);
  }
}
