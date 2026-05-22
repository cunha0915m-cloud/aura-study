import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/chat_bubble.dart';

/// Ecrã do Aura AI — chat estilo ChatGPT.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  Future<void> _send() async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    await context.read<ChatProvider>().send(text);
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                  child: Text('✨', style: TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aura AI',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                Text('Sempre disponível ✨',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            onPressed: chat.clear,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!context.watch<SettingsProvider>().isReadyToChat)
              _missingKeyBanner(context),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: chat.messages.length,
                itemBuilder: (_, i) => ChatBubble(message: chat.messages[i]),
              ),
            ),
            _suggestions(),
            _input(chat.loading),
          ],
        ),
      ),
    );
  }

  Widget _missingKeyBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Modo demo. Configura a tua chave Gemini ou OpenAI para respostas reais.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.settings),
            child: const Text('Configurar'),
          ),
        ],
      ),
    );
  }

  Widget _suggestions() {
    final items = [
      '✨ Cria um resumo de fotossíntese',
      '📐 Explica funções quadráticas',
      '🧪 Gera um quiz de Química',
    ];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (_, i) => ActionChip(
          label: Text(items[i]),
          onPressed: () {
            _controller.text = items[i].substring(2).trim();
            _send();
          },
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemCount: items.length,
      ),
    );
  }

  Widget _input(bool loading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: const InputDecoration(
                hintText: 'Pergunta algo à Aura AI…',
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: loading ? null : _send,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: loading ? Colors.grey : AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                loading ? Icons.hourglass_top : Icons.send_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
