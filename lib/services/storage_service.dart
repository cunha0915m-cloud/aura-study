import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

/// Upload de ficheiros (PDFs e imagens) para o Firebase Storage.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(File file, {String folder = 'posts'}) async {
    final name = '${const Uuid().v4()}_${file.path.split('/').last}';
    final ref = _storage.ref().child('$folder/$name');
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }
}
