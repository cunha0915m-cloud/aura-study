import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider de IA (escolhido pelo utilizador em Definições).
/// - [free]: Pollinations.ai (sem chave, GPT-style grátis)
/// - [gemini]: Google Gemini (chave grátis em ai.google.dev)
/// - [openai]: OpenAI (chave paga)
/// - [anthropic]: Anthropic Claude (chave paga/grátis)
/// - [ollama]: Servidor local/remoto de Ollama do utilizador
enum AiProvider { free, gemini, openai, anthropic, ollama }

/// Persiste configurações da IA + outras prefs.
class SettingsProvider extends ChangeNotifier {
  static const _kKey = 'ai_api_key';
  static const _kProvider = 'ai_provider';

  String _apiKey = '';
  AiProvider _provider = AiProvider.free;
  bool _ready = false;

  String get apiKey => _apiKey;
  AiProvider get provider => _provider;
  bool get ready => _ready;
  /// Providers [free] e [ollama] não precisam de chave API obrigatória.
  bool get isReadyToChat =>
      _provider == AiProvider.free ||
      _provider == AiProvider.ollama ||
      _apiKey.trim().isNotEmpty;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _apiKey = p.getString(_kKey) ?? '';
    final pv = p.getString(_kProvider);
    _provider = switch (pv) {
      'openai' => AiProvider.openai,
      'gemini' => AiProvider.gemini,
      'anthropic' => AiProvider.anthropic,
      'ollama' => AiProvider.ollama,
      _ => AiProvider.free,
    };
    _ready = true;
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key.trim();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kKey, _apiKey);
    notifyListeners();
  }

  Future<void> setProvider(AiProvider provider) async {
    _provider = provider;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kProvider, provider.name);
    notifyListeners();
  }
}
