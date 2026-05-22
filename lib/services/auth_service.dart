import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';

/// Encapsula autenticação. Se Firebase não estiver inicializado, usa
/// **fallback local** (SharedPreferences) — perfeito para dev/demo.
class AuthService {
  static const _uuid = Uuid();
  static const _kUsers = 'local_auth_users'; // mapa email → {password,name,uid}
  static const _kSession = 'local_auth_session'; // uid do user atual

  // Stream para emitir mudanças no fallback local.
  final _localCtrl = StreamController<UserModel?>.broadcast();

  bool get _firebaseReady => AppConfig.useFirebase;

  // ───────── Stream ─────────
  Stream<UserModel?> userChanges() {
    if (_firebaseReady) {
      return FirebaseAuth.instance.authStateChanges().asyncMap((u) async {
        if (u == null) return null;
        final db = FirebaseFirestore.instance;
        final doc = await db.collection('users').doc(u.uid).get();
        if (doc.exists) return UserModel.fromMap(u.uid, doc.data()!);
        final model = UserModel(
          uid: u.uid,
          name: u.displayName ?? 'Estudante',
          email: u.email ?? '',
          photoUrl: u.photoURL,
        );
        await db.collection('users').doc(u.uid).set(model.toMap());
        return model;
      });
    }
    // local fallback: emite o utilizador atual da sessão guardada
    _emitLocalSession();
    return _localCtrl.stream;
  }

  Future<void> _emitLocalSession() async {
    final user = await _currentLocalUser();
    _localCtrl.add(user);
  }

  // ───────── Sign in ─────────
  Future<UserModel> signIn(String email, String password) async {
    if (_firebaseReady) {
      final res = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);
      return _loadOrCreate(res.user!);
    }
    return _localSignIn(email, password);
  }

  // ───────── Sign up ─────────
  Future<UserModel> signUp(String name, String email, String password) async {
    if (_firebaseReady) {
      final res = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await res.user!.updateDisplayName(name);
      final model = UserModel(uid: res.user!.uid, name: name, email: email);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(model.uid)
          .set(model.toMap());
      return model;
    }
    return _localSignUp(name, email, password);
  }

  // ───────── Google ─────────
  Future<UserModel> signInWithGoogle() async {
    if (!_firebaseReady) {
      throw Exception(
          'Login Google requer Firebase configurado. Usa email/password ou convidado.');
    }
    final google = GoogleSignIn();
    final account = await google.signIn();
    if (account == null) throw Exception('Cancelado pelo utilizador');
    final auth = await account.authentication;
    final cred = GoogleAuthProvider.credential(
        idToken: auth.idToken, accessToken: auth.accessToken);
    final res = await FirebaseAuth.instance.signInWithCredential(cred);
    return _loadOrCreate(res.user!);
  }

  Future<UserModel> _loadOrCreate(User u) async {
    final db = FirebaseFirestore.instance;
    final ref = db.collection('users').doc(u.uid);
    final doc = await ref.get();
    if (doc.exists) return UserModel.fromMap(u.uid, doc.data()!);
    final model = UserModel(
      uid: u.uid,
      name: u.displayName ?? 'Estudante',
      email: u.email ?? '',
      photoUrl: u.photoURL,
    );
    await ref.set(model.toMap());
    return model;
  }

  // ───────── Password reset ─────────
  Future<void> resetPassword(String email) async {
    if (_firebaseReady) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return;
    }
    // No fallback local, removemos a password (forçando re-registo).
    final users = await _readUsers();
    if (!users.containsKey(email.toLowerCase())) {
      throw Exception('Email não registado');
    }
    // simulação — apenas toast no UI
  }

  // ───────── Sign out ─────────
  Future<void> signOut() async {
    if (_firebaseReady) {
      await GoogleSignIn().signOut().catchError((_) => null);
      await FirebaseAuth.instance.signOut();
      return;
    }
    final p = await SharedPreferences.getInstance();
    await p.remove(_kSession);
    _localCtrl.add(null);
  }

  // ═════════════════════════════════════════════════
  // LOCAL FALLBACK (SharedPreferences) — dev/demo
  // ═════════════════════════════════════════════════

  String _hash(String pwd) =>
      sha256.convert(utf8.encode('aura$pwd')).toString();

  Future<Map<String, Map<String, dynamic>>> _readUsers() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kUsers);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded
        .map((k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)));
  }

  Future<void> _writeUsers(Map<String, Map<String, dynamic>> users) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kUsers, jsonEncode(users));
  }

  Future<UserModel?> _currentLocalUser() async {
    final p = await SharedPreferences.getInstance();
    final uid = p.getString(_kSession);
    if (uid == null) return null;
    final users = await _readUsers();
    final entry =
        users.entries.where((e) => e.value['uid'] == uid).firstOrNull;
    if (entry == null) return null;
    return UserModel(
      uid: uid,
      name: entry.value['name'] as String,
      email: entry.key,
    );
  }

  Future<UserModel> _localSignIn(String email, String password) async {
    final users = await _readUsers();
    final key = email.trim().toLowerCase();
    final entry = users[key];
    if (entry == null) throw Exception('Email não registado.');
    if (entry['password'] != _hash(password)) {
      throw Exception('Palavra-passe incorreta.');
    }
    final p = await SharedPreferences.getInstance();
    await p.setString(_kSession, entry['uid'] as String);
    final model = UserModel(
      uid: entry['uid'] as String,
      name: entry['name'] as String,
      email: key,
    );
    _localCtrl.add(model);
    return model;
  }

  Future<UserModel> _localSignUp(
      String name, String email, String password) async {
    final users = await _readUsers();
    final key = email.trim().toLowerCase();
    if (users.containsKey(key)) {
      throw Exception('Já existe uma conta com este email.');
    }
    final uid = _uuid.v4();
    users[key] = {
      'uid': uid,
      'name': name,
      'password': _hash(password),
    };
    await _writeUsers(users);
    final p = await SharedPreferences.getInstance();
    await p.setString(_kSession, uid);
    final model = UserModel(uid: uid, name: name, email: key);
    _localCtrl.add(model);
    return model;
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
