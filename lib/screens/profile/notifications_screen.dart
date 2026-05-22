import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _items = [
    {'icon': '❤️', 'title': 'Mariana gostou do teu resumo', 'time': 'Há 2 min'},
    {
      'icon': '💬',
      'title': 'Novo comentário em "Os Lusíadas"',
      'time': 'Há 1h'
    },
    {'icon': '🏆', 'title': 'Subiste para o nível 2!', 'time': 'Ontem'},
    {'icon': '🔥', 'title': 'Streak de 7 dias!', 'time': 'Ontem'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final n = _items[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text(n['icon']!, style: const TextStyle(fontSize: 18)),
            ),
            title: Text(n['title']!),
            subtitle: Text(n['time']!),
          );
        },
      ),
    );
  }
}
