import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/subject_chip.dart';

/// Upload de conteúdos (PDFs, imagens, resumos).
class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  String _subject = Subjects.all.first;
  String? _attachment;

  Future<void> _pickPdf() async {
    try {
      final res = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (res != null && res.files.isNotEmpty) {
        setState(() => _attachment = res.files.first.name);
      }
    } catch (e) {
      _toast('Erro a abrir picker: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final img = await picker.pickImage(source: ImageSource.gallery);
      if (img != null) setState(() => _attachment = img.name);
    } catch (e) {
      _toast('Erro a abrir galeria: $e');
    }
  }

  void _resumo() => setState(() => _attachment = 'Resumo (texto)');

  void _publish() {
    if (_title.text.trim().isEmpty) {
      _toast('Adiciona um título.');
      return;
    }
    final user = context.read<AuthProvider>().user;
    context.read<FeedProvider>().createPost(
          authorId: user?.uid ?? 'guest',
          authorName: user?.name ?? 'Convidado',
          authorPhoto: user?.photoUrl,
          title: _title.text.trim(),
          description: _desc.text.trim(),
          subject: _subject,
          attachmentName: _attachment,
        );
    _toast('✨ Publicado no feed!');
    _title.clear();
    _desc.clear();
    setState(() => _attachment = null);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partilhar conteúdo')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _attachBtn(
                      icon: Icons.picture_as_pdf_rounded,
                      label: 'PDF',
                      onTap: _pickPdf,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _attachBtn(
                      icon: Icons.image_rounded,
                      label: 'Imagem',
                      onTap: _pickImage,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _attachBtn(
                      icon: Icons.note_alt_rounded,
                      label: 'Resumo',
                      onTap: _resumo,
                    ),
                  ),
                ],
              ),
              if (_attachment != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text('📎 Anexado: $_attachment',
                      style: const TextStyle(color: AppColors.primary)),
                ),
              const SizedBox(height: 20),
              CustomTextField(
                  controller: _title,
                  hint: 'Título',
                  icon: Icons.title_rounded),
              const SizedBox(height: 12),
              TextField(
                controller: _desc,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                    hintText: 'Descrição / conteúdo do resumo…'),
              ),
              const SizedBox(height: 18),
              const Text('Disciplina',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Subjects.all
                    .map((s) => SubjectChip(
                          subject: s,
                          selected: _subject == s,
                          onTap: () => setState(() => _subject = s),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                  label: 'Publicar',
                  onPressed: _publish,
                  icon: Icons.send_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attachBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: dark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
