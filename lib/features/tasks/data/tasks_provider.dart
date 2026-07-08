import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Task {
  final String id;
  final String title;
  final String project;
  final List<String> tags;
  final DateTime? completedAt;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.project,
    this.tags = const [],
    this.completedAt,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'project': project,
        'tags': tags,
        'completedAt': completedAt?.toIso8601String(),
        'isCompleted': isCompleted,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        project: json['project'] as String,
        tags: (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );

  Task copyWith({
    String? title,
    String? project,
    List<String>? tags,
    DateTime? completedAt,
    bool? isCompleted,
  }) =>
      Task(
        id: id,
        title: title ?? this.title,
        project: project ?? this.project,
        tags: tags ?? this.tags,
        completedAt: completedAt ?? this.completedAt,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}


class TasksNotifier extends Notifier<List<Task>> {
  static const _prefsKey = 'flowstate_tasks';

  @override
  List<Task> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final list = (jsonDecode(raw) as List)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefsKey, jsonEncode(state.map((t) => t.toJson()).toList()));
  }

  void addTask(String title, String project, [List<String> tags = const []]) {
    state = [
      ...state,
      Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        project: project,
        tags: tags,
      ),
    ];
    _save();
  }

  void editTask(String id, String title, String project, [List<String>? tags]) {
    state = state
        .map((t) => t.id == id ? t.copyWith(title: title, project: project, tags: tags) : t)
        .toList();
    _save();
  }

  void toggleTask(String id) {
    state = state.map((t) {
      if (t.id == id) {
        final nowCompleted = !t.isCompleted;
        return t.copyWith(
          isCompleted: nowCompleted,
          completedAt: nowCompleted ? DateTime.now() : null,
        );
      }
      return t;
    }).toList();
    _save();
  }

  void deleteTask(String id) {
    state = state.where((t) => t.id != id).toList();
    _save();
  }

  void reorderTasks(int oldIndex, int newIndex) {
    final list = List<Task>.from(state);
    if (newIndex > oldIndex) newIndex--;
    final task = list.removeAt(oldIndex);
    list.insert(newIndex, task);
    state = list;
    _save();
  }
}

final tasksProvider = NotifierProvider<TasksNotifier, List<Task>>(TasksNotifier.new);
