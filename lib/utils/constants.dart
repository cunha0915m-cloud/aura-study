import 'package:flutter/material.dart';

/// Paleta de cores oficial da Aura Study.
class AppColors {
  static const Color primary = Color(0xFF7B61FF);
  static const Color primaryDark = Color(0xFF5B45D6);
  static const Color accent = Color(0xFFB8A8FF);

  static const Color bgLight = Color(0xFFF7F7FB);
  static const Color bgDark = Color(0xFF0E0B14);
  static const Color cardDark = Color(0xFF1A1622);

  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
}

/// Disciplinas usadas no upload e feed.
class Subjects {
  static const List<String> all = [
    'Matemática',
    'Português',
    'Inglês',
    'História',
    'Geografia',
    'Ciências',
    'Física',
    'Química',
    'Biologia',
    'Programação',
    'Filosofia',
    'Arte',
  ];

  /// Emoji visual para cada disciplina.
  static String emoji(String s) {
    switch (s) {
      case 'Matemática':
        return '📐';
      case 'Português':
        return '📖';
      case 'Inglês':
        return '🇬🇧';
      case 'História':
        return '🏛️';
      case 'Geografia':
        return '🌍';
      case 'Ciências':
        return '🔬';
      case 'Física':
        return '⚛️';
      case 'Química':
        return '🧪';
      case 'Biologia':
        return '🧬';
      case 'Programação':
        return '💻';
      case 'Filosofia':
        return '🧠';
      case 'Arte':
        return '🎨';
      default:
        return '📚';
    }
  }
}

/// Configurações globais (chaves de API devem vir de variáveis de ambiente em produção).
class AppConfig {
  /// Flag global que determina se o Firebase está ativo e funcional.
  static bool useFirebase = false;

  /// Substitui pela tua chave OpenAI ou Gemini.
  static const String openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String anthropicApiKey = String.fromEnvironment('ANTHROPIC_API_KEY');

  static const String aiSystemPrompt =
      'És o Aura AI, um tutor de estudos amigável, conciso e motivador. '
      'Explicas conceitos passo a passo, crias resumos, exercícios e quizzes. '
      'Respondes sempre em português de Portugal, com tom claro e empático.';
}
