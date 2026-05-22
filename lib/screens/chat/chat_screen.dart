import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/chat_message.dart';
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
    final activeTitle = chat.active?.title ?? 'Aura AI';
    return Scaffold(
      drawer: _ChatsDrawer(),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activeTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const Text('Aura AI · sempre disponível ✨',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Nova conversa',
            onPressed: () => context.read<ChatProvider>().newSession(),
            icon: const Icon(Icons.add_comment_outlined),
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: 'Limpar conversa atual',
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

class _ChatsDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💬 As tuas Conversas',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 4),
                  Text('Organiza diferentes tópicos com a Aura AI',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    await context.read<ChatProvider>().newSession();
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Nova conversa'),
                ),
              ),
            ),
            const Divider(height: 0),
            Expanded(
              child: chat.sessions.isEmpty
                  ? const Center(child: Text('Sem conversas ainda.'))
                  : ListView.separated(
                      itemCount: chat.sessions.length,
                      separatorBuilder: (_, __) => const Divider(height: 0),
                      itemBuilder: (_, i) {
                        final s = chat.sessions[i];
                        final selected = s.id == chat.activeId;
                        return ListTile(
                          selected: selected,
                          selectedTileColor:
                              AppColors.primary.withOpacity(0.08),
                          leading: CircleAvatar(
                            backgroundColor: selected
                                ? AppColors.primary
                                : (dark
                                    ? Colors.white12
                                    : Colors.grey.shade200),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              color: selected
                                  ? Colors.white
                                  : AppColors.primary,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            s.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500),
                          ),
                          subtitle: Text(
                            '${DateFormat('dd/MM HH:mm').format(s.createdAt)} · ${s.messages.length} mensagens',
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) async {
                              if (v == 'rename') {
                                _renameDialog(context, s);
                              } else if (v == 'delete') {
                                await context
                                    .read<ChatProvider>()
                                    .deleteSession(s.id);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'rename',
                                child: Row(children: [
                                  Icon(Icons.edit_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text('Renomear'),
                                ]),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(children: [
                                  Icon(Icons.delete_outline,
                                      size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Eliminar',
                                      style: TextStyle(color: Colors.red)),
                                ]),
                              ),
                            ],
                          ),
                          onTap: () {
                            context
                                .read<ChatProvider>()
                                .selectSession(s.id);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _renameDialog(BuildContext context, ChatSession s) {
    final ctrl = TextEditingController(text: s.title);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Renomear conversa'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Novo título'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              context.read<ChatProvider>().renameSession(s.id, ctrl.text);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
