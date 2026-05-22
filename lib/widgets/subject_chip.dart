import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Chip de disciplina para o feed e filtros.
class SubjectChip extends StatelessWidget {
  final String subject;
  final bool selected;
  final VoidCallback? onTap;

  const SubjectChip({
    super.key,
    required this.subject,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : (dark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (dark ? Colors.white12 : Colors.black12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(Subjects.emoji(subject), style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              subject,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : (dark ? Colors.white : Colors.black87),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
