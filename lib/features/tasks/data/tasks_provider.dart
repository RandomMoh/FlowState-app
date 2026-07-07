import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Task {
  final String id;
  final String title;
  final String project;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.project,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'project': project,
        'isCompleted': isCompleted,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        project: json['project'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );

  Task copyWith({String? title, String? project, bool? isCompleted}) => Task(
        id: id,
        title: title ?? this.title,
        project: project ?? this.project,
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

  void addTask(String title, String project) {
    state = [
      ...state,
      Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        project: project,
      ),
    ];
    _save();
  }

  void editTask(String id, String title, String project) {
    state = state
        .map((t) => t.id == id ? t.copyWith(title: title, project: project) : t)
        .toList();
    _save();
  }

  void toggleTask(String id) {
    state = state
        .map((t) => t.id == id ? t.copyWith(isCompleted: !t.isCompleted) : t)
        .toList();
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
