import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().register(
          _name.text.trim(),
          _email.text.trim(),
          _password.text,
        );
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AuthProvider>().error ?? 'Erro')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cria a tua conta ✨',
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text(
                  'Junta-te à comunidade Aura Study.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 28),
                CustomTextField(
                  controller: _name,
                  hint: 'Nome',
                  icon: Icons.person_outline,
                  validator: (v) =>
                      v == null || v.trim().length < 2 ? 'Nome inválido' : null,
                ),
                const SizedBox(height: 14),
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
                  hint: 'Palavra-passe (mín. 6)',
                  icon: Icons.lock_outline,
                  obscure: true,
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Mín. 6 caracteres' : null,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Criar conta',
                  onPressed: _submit,
                  loading: auth.loading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
