import 'package:flutter/material.dart';

import '../../utils/constants.dart';

/// Ranking mock — em produção carregar de Firestore (orderBy xp desc).
class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  static const _users = [
    {'name': 'Mariana Costa', 'xp': 4820, 'level': 12},
    {'name': 'João Almeida', 'xp': 3915, 'level': 10},
    {'name': 'Sofia Pereira', 'xp': 3402, 'level': 9},
    {'name': 'Tu', 'xp': 120, 'level': 1},
    {'name': 'Pedro Santos', 'xp': 90, 'level': 1},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ranking')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _users.length,
        itemBuilder: (_, i) {
          final u = _users[i];
          final medal = i == 0
              ? '🥇'
              : i == 1
                  ? '🥈'
                  : i == 2
                      ? '🥉'
                      : '#${i + 1}';
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: u['name'] == 'Tu'
                  ? AppColors.primary.withOpacity(0.1)
                  : Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                SizedBox(
                    width: 36,
                    child: Text(medal,
                        style: const TextStyle(fontSize: 22))),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u['name'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text('Nível ${u['level']}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Text('${u['xp']} XP',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }
}
