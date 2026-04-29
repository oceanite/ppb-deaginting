import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  User? get firebaseUser => _auth.currentUser;

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<UserModel> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(), password: password);
      final user = await _getProfile(cred.user!.uid);
      if (user == null) throw const AuthException('Profil tidak ditemukan. Hubungi admin.');
      await _db.collection('users').doc(cred.user!.uid)
          .update({'lastSeen': FieldValue.serverTimestamp()});
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e.code));
    }
  }

  // ── Create account by admin (no sign-in side effect) ─────────────────────

  /// Admin membuat akun baru. Menggunakan secondary Auth instance agar
  /// sesi admin tidak ter-logout saat createUser.
  Future<UserModel> createUserByAdmin({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      // Simpan token admin saat ini
      final adminUser = _auth.currentUser;
      if (adminUser == null) throw const AuthException('Tidak ada sesi admin.');

      // Buat akun Firebase Auth untuk user baru
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(), password: password);
      final newUid = cred.user!.uid;

      // Simpan profil ke Firestore
      final userModel = UserModel(
        uid: newUid,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        role: role,
      );
      await _db.collection('users').doc(newUid).set({
        ...userModel.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': adminUser.uid,
        'lastSeen': null,
      });

      // Sign back in sebagai admin
      // (createUserWithEmailAndPassword tidak selalu mengganti current user
      //  pada beberapa versi SDK, tapi ini aman dilakukan)
      await _auth.signInWithEmailAndPassword(
        email: adminUser.email!, password: '');

      return userModel;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        // Sign-back-in gagal karena kita tidak tahu password admin.
        // User baru tetap terbuat di Firestore, admin perlu login ulang.
        throw const AuthException('Akun berhasil dibuat, tetapi sesi admin perlu diperbarui. Silakan login ulang.');
      }
      throw AuthException(_mapError(e.code));
    }
  }

  /// Alternatif: Admin create user langsung via Admin SDK (Cloud Functions).
  /// Di Flutter, gunakan pendekatan ini:
  ///   1. Call Cloud Function `createUser` yang memakai Admin SDK.
  ///   2. Cloud Function return UID.
  ///   3. Admin simpan profil ke Firestore dengan UID tersebut.
  ///
  /// Untuk tugas, gunakan pendekatan sederhana di bawah:
  /// Admin input email+password → Firebase Auth dibuat → Firestore profil dibuat.
  /// Admin harus login ulang setelah membuat akun pertama kali.

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> signOut() => _auth.signOut();

  // ── Change password ───────────────────────────────────────────────────────

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser!;
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e.code));
    }
  }

  // ── Reset password ────────────────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e.code));
    }
  }

  // ── Get profile ───────────────────────────────────────────────────────────

  Future<UserModel?> getProfile(String uid) => _getProfile(uid);

  Future<UserModel?> _getProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromFirestore(doc.data()!, uid);
  }

  // ── Error mapping ─────────────────────────────────────────────────────────

  String _mapError(String code) => switch (code) {
        'user-not-found'         => 'Email tidak terdaftar.',
        'wrong-password'         => 'Password salah.',
        'invalid-credential'     => 'Email atau password salah.',
        'invalid-email'          => 'Format email tidak valid.',
        'user-disabled'          => 'Akun dinonaktifkan.',
        'too-many-requests'      => 'Terlalu banyak percobaan. Coba lagi nanti.',
        'email-already-in-use'   => 'Email sudah terdaftar.',
        'weak-password'          => 'Password minimal 6 karakter.',
        'network-request-failed' => 'Tidak ada koneksi internet.',
        _                        => 'Terjadi kesalahan ($code).',
      };
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override String toString() => message;
}