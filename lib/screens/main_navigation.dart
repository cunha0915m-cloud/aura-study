import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'home/home_screen.dart';
import 'chat/chat_screen.dart';
import 'upload/upload_screen.dart';
import 'study/study_screen.dart';
import 'profile/profile_screen.dart';

/// Wrapper com Bottom Navigation Bar (estilo iOS, sombras suaves).
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    ChatScreen(),
    UploadScreen(),
    StudyScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: dark ? AppColors.cardDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _navItem(Icons.home_rounded, 'Início', 0),
                _navItem(Icons.auto_awesome_rounded, 'Aura AI', 1),
                _navItem(Icons.add_circle_rounded, 'Criar', 2, primary: true),
                _navItem(Icons.school_rounded, 'Estudar', 3),
                _navItem(Icons.person_rounded, 'Perfil', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int i, {bool primary = false}) {
    final selected = _index == i;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = selected
        ? AppColors.primary
        : (dark ? Colors.white60 : Colors.black54);

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _index = i),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: primary ? AppColors.primary : color, size: primary ? 32 : 26),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
