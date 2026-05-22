import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context
        .read<AuthProvider>()
        .login(_email.text.trim(), _password.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else {
      _showError(context.read<AuthProvider>().error);
    }
  }

  Future<void> _google() async {
    final ok = await context.read<AuthProvider>().loginWithGoogle();
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else {
      _showError(context.read<AuthProvider>().error);
    }
  }

  /// Permite "entrar como convidado" — útil para experimentar a app sem Firebase.
  void _guest() => Navigator.pushReplacementNamed(context, AppRoutes.main);

  void _showError(String? msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg ?? 'Erro')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                      child: Text('✨', style: TextStyle(fontSize: 32))),
                ),
                const SizedBox(height: 24),
                const Text('Bem-vindo de volta 👋',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text(
                  'Inicia sessão e continua a aprender.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _email,
                  hint: 'Email',
                  icon: Icons.email_outlined,
                  type: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Email inválido' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _password,
                  hint: 'Palavra-passe',
                  icon: Icons.lock_outline,
                  obscure: true,
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Mín. 6 caracteres' : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.forgot),
                    child: const Text('Esqueci-me da palavra-passe'),
                  ),
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  label: 'Entrar',
                  onPressed: _submit,
                  loading: auth.loading,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('ou',
                          style: TextStyle(color: Colors.grey[600])),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _google,
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text('Continuar com Google'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _guest,
                  child: const Text('Continuar como convidado →'),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.register),
                    child: const Text.rich(
                      TextSpan(text: 'Não tens conta? ', children: [
                        TextSpan(
                          text: 'Cria uma',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
