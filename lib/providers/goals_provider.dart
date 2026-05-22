import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../services/firestore_service.dart';
import '../utils/constants.dart';

/// Objetivo de estudo com gamificação (XP por concluir).
class Goal {
  final String id;
  final String subject;
  String text;
  bool done;
  int xp;
  DateTime createdAt;

  Goal({
    required this.id,
    required this.subject,
    required this.text,
    this.done = false,
    this.xp = 10,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'text': text,
        'done': done,
        'xp': xp,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Goal.fromJson(Map<String, dynamic> j) => Goal(
        id: j['id'] as String,
        subject: j['subject'] as String,
        text: j['text'] as String,
        done: j['done'] as bool? ?? false,
        xp: j['xp'] as int? ?? 10,
        createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
      );
}

/// Provider global de objetivos com persistência local e real no Firestore.
class GoalsProvider extends ChangeNotifier {
  static const _kGoals = 'goals_v1';
  static const _kXp = 'user_xp';
  static const _uuid = Uuid();
  final FirestoreService _fs = FirestoreService();

  final List<Goal> _goals = [];
  int _xp = 0;
  bool _loaded = false;
  String? _userId;

  List<Goal> get all => List.unmodifiable(_goals);
  List<Goal> bySubject(String subject) =>
      _goals.where((g) => g.subject == subject).toList();
  List<Goal> get today {
    final now = DateTime.now();
    return _goals.where((g) {
      return g.createdAt.year == now.year &&
          g.createdAt.month == now.month &&
          g.createdAt.day == now.day;
    }).toList();
  }

  int get xp => _xp;

  /// XP necessário para chegar ao nível n (curva progressiva).
  /// Nível 1 = 0 XP, Nível 2 = 100, Nível 3 = 250, Nível 4 = 450...
  /// Fórmula: xp(n) = 50 * n * (n-1).
  int _xpRequiredFor(int level) => 50 * level * (level - 1);

  int get level {
    int lvl = 1;
    while (_xpRequiredFor(lvl + 1) <= _xp) {
      lvl++;
    }
    return lvl;
  }

  int get xpAtCurrentLevel => _xp - _xpRequiredFor(level);
  int get xpForNextLevel =>
      _xpRequiredFor(level + 1) - _xpRequiredFor(level);
  double get levelProgress =>
      xpForNextLevel == 0 ? 1.0 : xpAtCurrentLevel / xpForNextLevel;
  int get xpToNextLevel => xpForNextLevel - xpAtCurrentLevel;

  /// Título do nível atual.
  String get levelTitle {
    final l = level;
    if (l >= 30) return '🏆 Lenda';
    if (l >= 20) return '👑 Mestre';
    if (l >= 15) return '🚀 Especialista';
    if (l >= 10) return '⭐ Avançado';
    if (l >= 6) return '📚 Aprendiz';
    if (l >= 3) return '🌱 Estudante';
    return '✨ Iniciante';
  }

  int get goalsCompleted => _goals.where((g) => g.done).length;
  int get goalsTotal => _goals.length;
  double get globalProgress =>
      goalsTotal == 0 ? 0.0 : goalsCompleted / goalsTotal;

  GoalsProvider() {
    _load();
  }

  void updateSession(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      if (userId != null && AppConfig.useFirebase) {
        _syncWithFirestore();
      }
    }
  }

  Future<void> _syncWithFirestore() async {
    if (_userId == null || !AppConfig.useFirebase) return;
    try {
      final remoteGoals = await _fs.fetchGoals(_userId!);
      final remoteXp = await _fs.fetchUserXp(_userId!);
      
      _xp = remoteXp;
      if (remoteGoals.isNotEmpty) {
        _goals.clear();
        _goals.addAll(remoteGoals);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Erro ao sincronizar objetivos com Firestore: $e');
    }
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _xp = p.getInt(_kXp) ?? 0;
    final raw = p.getString(_kGoals);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _goals
        ..clear()
        ..addAll(list.map((e) => Goal.fromJson(Map<String, dynamic>.from(e))));
    } else {
      // Seed inicial
      _seedDefaults();
      await _save();
    }
    _loaded = true;
    notifyListeners();
  }

  void _seedDefaults() {
    final seeds = {
      'Matemática': ['Funções quadráticas — exercícios', 'Geometria analítica'],
      'Português': ['Os Lusíadas — Canto I', 'Gramática'],
      'Programação': ['Dart: variáveis e funções', 'Construir mini-projeto'],
    };
    seeds.forEach((subject, items) {
      for (final t in items) {
        _goals.add(Goal(id: _uuid.v4(), subject: subject, text: t, xp: 15));
      }
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        _kGoals, jsonEncode(_goals.map((g) => g.toJson()).toList()));
    await p.setInt(_kXp, _xp);
  }

  Future<Goal> add(String subject, String text, {int xp = 10}) async {
    final g = Goal(id: _uuid.v4(), subject: subject, text: text, xp: xp);
    _goals.add(g);
    await _save();
    notifyListeners();

    // Envia ao Firestore
    if (_userId != null && AppConfig.useFirebase) {
      _fs.saveGoal(_userId!, g).catchError((e) {
        debugPrint('⚠️ Erro ao salvar objetivo no Firestore: $e');
      });
    }

    return g;
  }

  Future<void> remove(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _save();
    notifyListeners();

    // Elimina no Firestore
    if (_userId != null && AppConfig.useFirebase) {
      _fs.deleteGoal(_userId!, id).catchError((e) {
        debugPrint('⚠️ Erro ao eliminar objetivo no Firestore: $e');
      });
    }
  }

  /// Marca/desmarca um objetivo. Soma/subtrai XP.
  Future<int> toggleDone(String id) async {
    final i = _goals.indexWhere((g) => g.id == id);
    if (i == -1) return 0;
    _goals[i].done = !_goals[i].done;
    final delta = _goals[i].done ? _goals[i].xp : -_goals[i].xp;
    _xp = (_xp + delta).clamp(0, 999999);
    await _save();
    notifyListeners();

    // Sincroniza estado e XP no Firestore
    if (_userId != null && AppConfig.useFirebase) {
      _fs.saveGoal(_userId!, _goals[i]).catchError((e) => null);
      _fs.saveUserXp(_userId!, _xp).catchError((e) => null);
    }

    return delta;
  }

  Future<void> edit(String id, String newText) async {
    final i = _goals.indexWhere((g) => g.id == id);
    if (i == -1) return;
    _goals[i].text = newText;
    await _save();
    notifyListeners();

    // Sincroniza no Firestore
    if (_userId != null && AppConfig.useFirebase) {
      _fs.saveGoal(_userId!, _goals[i]).catchError((e) => null);
    }
  }
}
