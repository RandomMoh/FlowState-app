import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FocusSession {
  final DateTime date;
  final int durationMinutes;

  FocusSession({required this.date, required this.durationMinutes});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'durationMinutes': durationMinutes,
      };

  factory FocusSession.fromJson(Map<String, dynamic> json) => FocusSession(
        date: DateTime.parse(json['date'] as String),
        durationMinutes: json['durationMinutes'] as int,
      );
}


class StatsNotifier extends Notifier<List<FocusSession>> {
  static const _prefsKey = 'flowstate_sessions';

  @override
  List<FocusSession> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final list = (jsonDecode(raw) as List)
          .map((e) => FocusSession.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefsKey, jsonEncode(state.map((s) => s.toJson()).toList()));
  }

  /// Called when a focus session completes
  void recordSession(int durationMinutes) {
    state = [
      ...state,
      FocusSession(date: DateTime.now(), durationMinutes: durationMinutes),
    ];
    _save();
  }

  /// Returns total minutes for each of the last 7 days (index 0 = oldest)
  List<double> get weeklyMinutes {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return state
          .where((s) =>
              s.date.year == day.year &&
              s.date.month == day.month &&
              s.date.day == day.day)
          .fold<double>(0, (sum, s) => sum + s.durationMinutes);
    });
  }

  int get totalMinutesThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return state
        .where((s) => s.date.isAfter(weekStart))
        .fold(0, (sum, s) => sum + s.durationMinutes);
  }

  int get totalSessionsAllTime => state.length;
}

final statsProvider =
    NotifierProvider<StatsNotifier, List<FocusSession>>(StatsNotifier.new);
