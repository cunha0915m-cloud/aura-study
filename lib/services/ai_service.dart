import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../providers/settings_provider.dart';
import '../utils/constants.dart';

/// Serviço de IA — suporta **Claude** (Anthropic, recomendado), **Gemini** e **OpenAI**.
/// A chave é configurada nas Definições da app (sem rebuild necessário).
class AiService {
  static const _openAiUrl = 'https://api.openai.com/v1/chat/completions';
  static const _geminiBase =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const _anthropicUrl = 'https://api.anthropic.com/v1/messages';
  static const _anthropicModel = 'claude-sonnet-4-20250514';
  static const _anthropicVersion = '2023-06-01';

  /// Envia o histórico e devolve a resposta da IA.
  Future<String> sendMessage(
    List<Map<String, String>> history, {
    required AiProvider provider,
    required String apiKey,
  }) async {
    final openAiKey =
        apiKey.isNotEmpty ? apiKey : AppConfig.openAiApiKey;
    final geminiKey =
        apiKey.isNotEmpty ? apiKey : AppConfig.geminiApiKey;
    final anthropicKey =
        apiKey.isNotEmpty ? apiKey : AppConfig.anthropicApiKey;

    try {
      switch (provider) {
        case AiProvider.free:
          // Usa Claude (Anthropic) se houver chave, caso contrário fallback para a IA grátis (Pollinations)
          if (anthropicKey.isNotEmpty) {
            return await _anthropic(history, anthropicKey);
          }
          return await _pollinations(history);
        case AiProvider.anthropic:
          if (anthropicKey.isEmpty) {
            return _noKeyResponse();
          }
          return await _anthropic(history, anthropicKey);
        case AiProvider.gemini:
          if (geminiKey.isEmpty) {
            return _noKeyResponse();
          }
          return await _gemini(history, geminiKey);
        case AiProvider.openai:
          if (openAiKey.isEmpty) {
            return _noKeyResponse();
          }
          return await _openai(history, openAiKey);
        case AiProvider.ollama:
          return await _ollama(history);
      }
    } catch (e) {
      debugPrint('⚠️ Erro no provider $provider: $e. Fazendo fallback para IA grátis...');
      try {
        return await _pollinations(history);
      } catch (errFallback) {
        return 'Ocorreu um erro ao contactar a IA. Verifica a tua ligação à Internet ou as chaves nas Definições. ⏳';
      }
    }
  }

  // ───────── Anthropic Claude ─────────
  Future<String> _anthropic(
      List<Map<String, String>> history, String key) async {
    // Anthropic usa system separado + lista de messages user/assistant
    final messages = history.map((m) => {
          'role': m['role'] == 'assistant' ? 'assistant' : 'user',
          'content': m['content'] ?? '',
        }).toList();

    final res = await http.post(
      Uri.parse(_anthropicUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': key,
        'anthropic-version': _anthropicVersion,
      },
      body: jsonEncode({
        'model': _anthropicModel,
        'max_tokens': 1024,
        'system':
            '${AppConfig.aiSystemPrompt} Responde sempre em português de Portugal. Sê conciso, direto e amigável.',
        'messages': messages,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Anthropic ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final content = data['content'] as List?;
    if (content == null || content.isEmpty) {
      throw Exception('Sem resposta da API Anthropic.');
    }

    // content é uma lista de blocos; o texto está nos blocos de tipo "text"
    return content
        .where((block) => block['type'] == 'text')
        .map((block) => block['text'] as String)
        .join()
        .trim();
  }

  // ───────── Gemini ─────────
  Future<String> _gemini(
      List<Map<String, String>> history, String key) async {
    final contents = [
      {
        'role': 'user',
        'parts': [
          {'text': AppConfig.aiSystemPrompt},
        ],
      },
      {
        'role': 'model',
        'parts': [
          {'text': 'Entendido. Estou pronto para ajudar! ✨'},
        ],
      },
      ...history.map((m) => {
            'role': m['role'] == 'assistant' ? 'model' : 'user',
            'parts': [
              {'text': m['content'] ?? ''}
            ],
          }),
    ];

    final url = Uri.parse(
        '$_geminiBase/gemini-2.0-flash:generateContent?key=$key');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': contents,
        'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 1024},
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('Gemini ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Sem resposta. Verifica a tua chave Gemini.');
    }
    final parts = candidates.first['content']['parts'] as List;
    return parts.map((p) => p['text']).join().toString().trim();
  }

  // ───────── OpenAI ─────────
  Future<String> _openai(
      List<Map<String, String>> history, String key) async {
    final res = await http.post(
      Uri.parse(_openAiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $key',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': AppConfig.aiSystemPrompt},
          ...history,
        ],
        'temperature': 0.7,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('OpenAI ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body);
    return data['choices'][0]['message']['content'] as String;
  }

  // ───────── Pollinations (free, no key) ─────────
  Future<String> _pollinations(List<Map<String, String>> history) async {
    final messagesList = [
      {
        'role': 'system',
        'content': '${AppConfig.aiSystemPrompt} Responde sempre em português de Portugal. Sê conciso, direto e amigável.'
      },
      ...history.map((m) => {
            'role': m['role'] == 'assistant' ? 'assistant' : 'user',
            'content': m['content'] ?? '',
          }),
    ];

    try {
      final res = await http.post(
        Uri.parse('https://text.pollinations.ai/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: jsonEncode({
          'messages': messagesList,
          'model': 'openai',
          'private': true,
          'json': false,
        }),
      );

      if (res.statusCode == 200 && res.body.trim().isNotEmpty) {
        return res.body.trim();
      }
    } catch (e) {
      debugPrint('⚠️ Falha no modelo default Pollinations: $e. A tentar fallback Mistral...');
    }

    try {
      final resMistral = await http.post(
        Uri.parse('https://text.pollinations.ai/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: jsonEncode({
          'messages': messagesList,
          'model': 'mistral',
          'private': true,
          'json': false,
        }),
      );

      if (resMistral.statusCode == 200 && resMistral.body.trim().isNotEmpty) {
        return resMistral.body.trim();
      }
    } catch (err) {
      debugPrint('⚠️ Erro no fallback Mistral da Pollinations: $err');
    }

    return 'Olá! Desculpa, os servidores da IA pública gratuita estão com sobrecarga de momento. ⏳\n\n'
        '**Dica Aura Study:** Se tiveres uma chave de API da Gemini (Google), Claude (Anthropic) ou OpenAI, podes inseri-la nas **Definições da app** para teres acesso imediato aos modelos mais rápidos do mundo de forma 100% estável!';
  }

  // ───────── Ollama Server ─────────
  Future<String> _ollama(List<Map<String, String>> history) async {
    final messages = [
      {'role': 'system', 'content': '${AppConfig.aiSystemPrompt} Responde sempre em português de Portugal.'},
      ...history.map((m) => {
            'role': m['role'] == 'assistant' ? 'assistant' : 'user',
            'content': m['content'] ?? '',
          }),
    ];

    // Fazemos um POST para o endpoint do Ollama
    final res = await http.post(
      Uri.parse('https://apichat.epvc.pt/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': 'mistral', // Modelo comum em servidores de estudo. Se o servidor do utilizador tiver outro (ex: llama3, gemma), o Ollama faz o load automático.
        'messages': messages,
        'stream': false,
      }),
    );

    if (res.statusCode != 200) {
      // Se o 'mistral' não estiver disponível, tentamos com 'llama3'
      final fallbackRes = await http.post(
        Uri.parse('https://apichat.epvc.pt/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'llama3',
          'messages': messages,
          'stream': false,
        }),
      );

      if (fallbackRes.statusCode != 200) {
        throw Exception('Ollama falhou nos modelos mistral e llama3. Código: ${fallbackRes.statusCode}');
      }
      
      final data = jsonDecode(utf8.decode(fallbackRes.bodyBytes));
      return data['message']['content'].toString().trim();
    }

    final data = jsonDecode(utf8.decode(res.bodyBytes));
    return data['message']['content'].toString().trim();
  }

  // ───────── Sem chave configurada ─────────
  String _noKeyResponse() {
    return '⚠️ **Chave de API não configurada.**\n\n'
        'Vai a **Definições → Aura AI** e insere a tua chave de API.\n\n'
        'Podes obter uma chave gratuita em:\n'
        '- **Claude (Anthropic):** https://console.anthropic.com\n'
        '- **Gemini (Google):** https://aistudio.google.com\n'
        '- **OpenAI:** https://platform.openai.com';
  }
}
