import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/constants.dart';

/// Definições da app: chave de IA, tema, sobre.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _keyCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>();
    _keyCtrl.text = s.apiKey;
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await context.read<SettingsProvider>().setApiKey(_keyCtrl.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Chave guardada. Aura AI pronta!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final settings = context.watch<SettingsProvider>();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Definições')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ───────── Aura AI ─────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: dark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('✨', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 10),
                      const Text('Aura AI',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800)),
                      const Spacer(),
                      Icon(
                        settings.isReadyToChat
                            ? Icons.check_circle
                            : Icons.error_outline,
                        color: settings.isReadyToChat
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Provider'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _providerChip(settings, AiProvider.free, 'Free', Icons.bolt),
                      _providerChip(settings, AiProvider.gemini, 'Gemini', Icons.auto_awesome),
                      _providerChip(settings, AiProvider.openai, 'OpenAI', Icons.psychology_alt),
                      _providerChip(settings, AiProvider.anthropic, 'Claude', Icons.science_rounded),
                      _providerChip(settings, AiProvider.ollama, 'Ollama', Icons.terminal_rounded),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (settings.provider == AiProvider.free)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Não precisas de chave! A Aura AI usa um modelo público GPT-style gratuito.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (settings.provider == AiProvider.ollama)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.computer_rounded, color: AppColors.primary),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Ollama ativo! A app enviará as perguntas para o teu servidor local em https://apichat.epvc.pt/api de forma totalmente privada.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    TextField(
                      controller: _keyCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: settings.provider == AiProvider.gemini
                            ? 'Cola a tua Gemini API Key (AIza…)'
                            : settings.provider == AiProvider.openai
                                ? 'Cola a tua OpenAI API Key (sk-…)'
                                : 'Cola a tua Claude API Key (sk-ant-…)',
                        prefixIcon: const Icon(Icons.key_rounded),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            IconButton(
                              icon: const Icon(Icons.paste_rounded),
                              onPressed: () async {
                                final data =
                                    await Clipboard.getData('text/plain');
                                if (data?.text != null) {
                                  _keyCtrl.text = data!.text!.trim();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Guardar chave'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      settings.provider == AiProvider.gemini
                          ? 'Obtém uma chave grátis em aistudio.google.com/apikey'
                          : settings.provider == AiProvider.openai
                              ? 'Cria uma chave em platform.openai.com/api-keys'
                              : 'Obtém uma chave em console.anthropic.com',
                      style: TextStyle(
                          fontSize: 12,
                          color: dark ? Colors.white60 : Colors.black54),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ───────── Aparência ─────────
            Container(
              decoration: BoxDecoration(
                color: dark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SwitchListTile.adaptive(
                secondary: const Icon(Icons.dark_mode_rounded,
                    color: AppColors.primary),
                title: const Text('Modo escuro'),
                value: theme.themeMode == ThemeMode.dark,
                onChanged: (_) => theme.toggle(),
              ),
            ),

            const SizedBox(height: 16),

            // ───────── Sobre ─────────
            Container(
              decoration: BoxDecoration(
                color: dark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded,
                        color: AppColors.primary),
                    title: const Text('Sobre a Aura Study'),
                    subtitle: const Text('Versão 1.0.0'),
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'Aura Study',
                      applicationVersion: '1.0.0',
                      applicationLegalese:
                          '✨ Plataforma educativa social com IA.',
                    ),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined,
                        color: AppColors.primary),
                    title: const Text('Privacidade'),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Privacidade'),
                        content: const Text(
                            'A tua chave de IA é guardada apenas no teu dispositivo (SharedPreferences). Nada é enviado para servidores nossos.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _providerChip(SettingsProvider settings, AiProvider provider, String label, IconData icon) {
    final selected = settings.provider == provider;
    return ChoiceChip(
      avatar: Icon(icon, size: 16, color: selected ? Colors.white : AppColors.primary),
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: selected ? Colors.white : null),
      onSelected: (val) {
        if (val) {
          settings.setProvider(provider);
        }
      },
    );
  }
}
