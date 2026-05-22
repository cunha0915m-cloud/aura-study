import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/task_item.dart';

/// Provider de tarefas do calendário (persistidas).
class TasksProvider extends ChangeNotifier {
  static const _key = 'calendar_tasks_v1';
  static const _uuid = Uuid();

  /// Map: 'yyyy-MM-dd' → List<TaskItem>
  final Map<String, List<TaskItem>> _byDay = {};

  TasksProvider() {
    _load();
  }

  String _k(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<TaskItem> tasksFor(DateTime d) =>
      List.unmodifiable(_byDay[_k(d)] ?? const []);

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw != null) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _byDay.clear();
      map.forEach((k, v) {
        _byDay[k] = (v as List)
            .map((e) => TaskItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });
    }
    // Seed amigável da primeira vez
    if (_byDay.isEmpty) {
      _byDay[_k(DateTime.now())] = [
        TaskItem(id: _uuid.v4(), text: 'Estudar Matemática 📐'),
        TaskItem(id: _uuid.v4(), text: 'Quiz de Inglês 🇬🇧', done: true),
      ];
      await _save();
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    final encoded = _byDay.map(
        (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()));
    await p.setString(_key, jsonEncode(encoded));
  }

  Future<void> add(DateTime day, String text) async {
    final list = _byDay.putIfAbsent(_k(day), () => []);
    list.add(TaskItem(id: _uuid.v4(), text: text));
    await _save();
    notifyListeners();
  }

  Future<void> remove(DateTime day, String id) async {
    _byDay[_k(day)]?.removeWhere((t) => t.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> toggleDone(DateTime day, String id) async {
    final list = _byDay[_k(day)];
    if (list == null) return;
    final idx = list.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    list[idx].done = !list[idx].done;
    await _save();
    notifyListeners();
  }

  bool dayHasTasks(DateTime d) => (_byDay[_k(d)] ?? const []).isNotEmpty;
}
