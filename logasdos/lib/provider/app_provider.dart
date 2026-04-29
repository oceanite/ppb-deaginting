import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../database/local_cache.dart';

class AppProvider extends ChangeNotifier {
  final _auth    = AuthService();
  final _fs      = FirestoreService();
  final _storage = StorageService();
  final _cache   = LocalCache.instance;
  final _notif   = NotificationService.instance;

  // ── State ─────────────────────────────────────────────────────────────────

  UserModel? _user;
  UserModel? get currentUser => _user;
  bool get isLoggedIn  => _user != null;
  bool get isAdmin     => _user?.role == UserRole.admin;
  bool get isDosen     => _user?.role == UserRole.dosen;
  bool get isAsdos     => _user?.role == UserRole.asdos;

  List<ClassModel>    _classes    = [];
  List<ActivityModel> _activities = [];
  List<UserModel>     _asdosList  = [];
  ActivityStats _stats = const ActivityStats(total:0,approved:0,pending:0,rejected:0);

  List<ClassModel>    get classes    => _classes;
  List<ActivityModel> get activities => _activities;
  List<UserModel>     get asdosList  => _asdosList;
  ActivityStats       get stats      => _stats;

  List<UserModel>  _allUsers   = [];
  List<UserModel>  _allDosen   = [];
  List<UserModel>  _allAsdos   = [];
  AdminStats? _adminStats;

  List<UserModel>  get allUsers    => _allUsers;
  List<UserModel>  get allDosen    => _allDosen;
  List<UserModel>  get allAsdos    => _allAsdos;
  AdminStats?      get adminStats  => _adminStats;

  bool    _loading        = false;
  bool    _uploading      = false;
  double  _uploadProgress = 0;
  String? _errorMessage;

  bool    get loading         => _loading;
  bool    get uploading       => _uploading;
  double  get uploadProgress  => _uploadProgress;
  String? get errorMessage    => _errorMessage;

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<String?> login(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _auth.signIn(email, password);
      await loadData();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    } finally { _setLoading(false); }
  }

  Future<String?> changePassword(String oldPw, String newPw) async {
    try {
      await _auth.changePassword(currentPassword: oldPw, newPassword: newPw);
      return null;
    } on AuthException catch (e) { return e.message; }
  }

  Future<String?> sendPasswordReset(String email) async {
    try { await _auth.sendPasswordReset(email); return null; }
    on AuthException catch (e) { return e.message; }
  }

  void setUserFromSession(UserModel user) {
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    // Cancel semua notifikasi terjadwal saat logout
    await _notif.cancelAll();

    _user       = null;
    _classes    = [];
    _activities = [];
    _asdosList  = [];
    _allUsers   = [];
    _allDosen   = [];
    _allAsdos   = [];
    _adminStats = null;
    _stats = const ActivityStats(total:0,approved:0,pending:0,rejected:0);
    notifyListeners();

    await Future.wait([
      _auth.signOut(),
      _cache.clearAll(),
    ]);
  }

  // ── Load data by role ─────────────────────────────────────────────────────

  Future<void> loadData() async {
    final u = _user;
    if (u == null) return;

    switch (u.role) {
      case UserRole.admin:
        await _loadAdminData();
      case UserRole.dosen:
        await _loadDosenData(u.uid);
      case UserRole.asdos:
        await _loadAsdosData(u.uid);
    }
    notifyListeners();
  }

  Future<void> _loadAdminData() async {
    _allUsers   = await _fs.getAllUsers();
    _allDosen   = _allUsers.where((u) => u.role == UserRole.dosen).toList();
    _allAsdos   = _allUsers.where((u) => u.role == UserRole.asdos).toList();
    _classes    = await _fs.getAllClasses();
    _activities = await _fs.getAllActivities();
    _adminStats = await _fs.getAdminStats();
  }

  Future<void> _loadDosenData(String uid) async {
    _classes    = await _fs.getClassesByDosen(uid);
    _activities = await _fs.getActivitiesByDosen(uid);
    _asdosList  = await _fs.getAsdosByDosen(uid);
  }

  Future<void> _loadAsdosData(String uid) async {
    final online = await _isOnline();
    if (online) {
      _classes    = await _fs.getClassesByAsdos(uid);
      _activities = await _fs.getActivitiesByAsdos(uid);
      _stats      = await _fs.getStats(uid);
      await _cache.cacheClasses(_classes);
      await _cache.cacheActivities(_activities);
    } else {
      _classes    = await _cache.getCachedClasses();
      _activities = await _cache.getCachedActivities(uid);
      _stats      = _computeStats(_activities);
    }

    // Jadwalkan ulang notifikasi setelah data kelas ter-load
    // (dipanggil baik online maupun offline)
    await _notif.rescheduleAll(_classes);
  }

  // ── Activity helpers ──────────────────────────────────────────────────────

  List<ActivityModel> filterActivities(ActivityStatus? status) =>
      status == null ? _activities : _activities.where((a) => a.status == status).toList();

  Future<List<ActivityModel>> getActivitiesForAsdos(String asdosId) async {
    final u = _user;
    if (u == null) return [];
    if (u.role == UserRole.dosen) return _fs.getActivitiesByDosenAndAsdos(u.uid, asdosId);
    if (u.role == UserRole.admin) return _fs.getActivitiesByAsdos(asdosId);
    return [];
  }

  Future<String?> submitActivity({
    required String classId, required String className,
    required ActivityCategory category, required String description,
    required ClassMode mode, required DateTime date,
    required String timeRange, File? photoFile,
  }) async {
    final u = _user;
    if (u == null) return 'Tidak ada sesi aktif.';
    _setLoading(true);
    try {
      String? uploadedPath, uploadedUrl;
      if (photoFile != null) {
        _uploading = true; _uploadProgress = 0; notifyListeners();
        final result = await _storage.uploadActivityPhoto(
          file: photoFile, asdosId: u.uid,
          onProgress: (p) { _uploadProgress = p; notifyListeners(); },
        );
        _uploading = false;
        if (result.startsWith('http')) uploadedUrl = result;
        else uploadedPath = result;
      }
      final activity = ActivityModel(
        id: '', classId: classId, className: className,
        asdosId: u.uid, asdosName: u.name,
        category: category, description: description.trim(),
        photoPath: uploadedPath, photoUrl: uploadedUrl,
        status: ActivityStatus.pending, mode: mode,
        date: date, timeRange: timeRange, createdAt: DateTime.now(),
      );
      final newId = await _fs.insertActivity(activity);
      final saved = activity.copyWith(id: newId);
      _activities = [saved, ..._activities];
      _stats = _computeStats(_activities);
      await _cache.cacheActivities([saved]);
      notifyListeners();
      return null;
    } catch (e) {
      return 'Gagal menyimpan: $e';
    } finally { _setLoading(false); _uploading = false; }
  }

  // ── Approval ──────────────────────────────────────────────────────────────

  Future<String?> approveActivity(String id) async {
    try {
      await _fs.updateActivityStatus(activityId: id, status: ActivityStatus.approved);
      _patchLocal(id, ActivityStatus.approved);

      // Notifikasi approval
      try {
        final act = _activities.firstWhere((a) => a.id == id);
        await _notif.showApprovalNotification(
          activityId: id,
          className: act.className,
          dosenName: _user?.name ?? 'Dosen',
        );
      } catch (_) {}

      return null;
    } catch (e) { return 'Gagal: $e'; }
  }

  Future<String?> rejectActivity(String id, {String? reason}) async {
    try {
      await _fs.updateActivityStatus(
          activityId: id,
          status: ActivityStatus.rejected,
          rejectReason: reason);
      _patchLocal(id, ActivityStatus.rejected, rejectReason: reason);

      // Notifikasi rejection
      try {
        final act = _activities.firstWhere((a) => a.id == id);
        await _notif.showRejectionNotification(
          activityId: id,
          className: act.className,
          dosenName: _user?.name ?? 'Dosen',
          reason: reason,
        );
      } catch (_) {}

      return null;
    } catch (e) { return 'Gagal: $e'; }
  }

  Future<String?> bulkApprove(List<String> ids) async {
    try {
      await _fs.bulkUpdateStatus(ids: ids, status: ActivityStatus.approved);
      for (final id in ids) _patchLocal(id, ActivityStatus.approved);
      return null;
    } catch (e) { return 'Gagal: $e'; }
  }

  Future<String?> bulkReject(List<String> ids) async {
    try {
      await _fs.bulkUpdateStatus(ids: ids, status: ActivityStatus.rejected);
      for (final id in ids) _patchLocal(id, ActivityStatus.rejected);
      return null;
    } catch (e) { return 'Gagal: $e'; }
  }

  void _patchLocal(String id, ActivityStatus status, {String? rejectReason}) {
    _activities = _activities.map((a) =>
        a.id == id ? a.copyWith(status: status, rejectReason: rejectReason) : a).toList();
    _stats = _computeStats(_activities);
    _cache.updateCachedStatus(id, status, rejectReason: rejectReason);
    notifyListeners();
  }

  // ── Admin: User management ────────────────────────────────────────────────

  Future<String?> adminCreateUser({
    required String name, required String email,
    required String password, required UserRole role,
  }) async {
    _setLoading(true);
    try {
      await _auth.createUserByAdmin(
          name: name, email: email, password: password, role: role);
      await _loadAdminData();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Gagal membuat akun: $e';
    } finally { _setLoading(false); }
  }

  Future<String?> adminUpdateUser(String uid, {String? name, UserRole? role}) async {
    try {
      await _fs.updateUser(uid, name: name, role: role);
      _allUsers = _allUsers.map((u) {
        if (u.uid != uid) return u;
        return UserModel(uid: u.uid, name: name ?? u.name, email: u.email, role: role ?? u.role);
      }).toList();
      _allDosen = _allUsers.where((u) => u.role == UserRole.dosen).toList();
      _allAsdos = _allUsers.where((u) => u.role == UserRole.asdos).toList();
      notifyListeners();
      return null;
    } catch (e) { return 'Gagal update: $e'; }
  }

  // ── Admin: Class management ───────────────────────────────────────────────

  Future<String?> adminCreateClass({
    required String name, required String dosenId, required String dosenName,
    required String startTime, required String endTime,
    required String room, required bool isOnline, required int dayOfWeek,
  }) async {
    _setLoading(true);
    try {
      final c = ClassModel(
        id: '', name: name, dosenId: dosenId, dosenName: dosenName,
        startTime: startTime, endTime: endTime, room: room,
        isOnline: isOnline, dayOfWeek: dayOfWeek,
      );
      final newId = await _fs.createClass(c);
      _classes.insert(0, c.copyWith(id: newId));
      notifyListeners();
      return null;
    } catch (e) { return 'Gagal: $e'; }
    finally { _setLoading(false); }
  }

  Future<String?> adminUpdateClass(ClassModel updated) async {
    try {
      await _fs.updateClass(updated);
      _classes = _classes.map((c) => c.id == updated.id ? updated : c).toList();
      notifyListeners();
      return null;
    } catch (e) { return 'Gagal update kelas: $e'; }
  }

  Future<String?> adminAssignAsdos(String classId, String asdosId) async {
    try {
      await _fs.addAsdosToClass(classId, asdosId);
      _classes = _classes.map((c) {
        if (c.id != classId) return c;
        if (c.asdosIds.contains(asdosId)) return c;
        return c.copyWith(asdosIds: [...c.asdosIds, asdosId]);
      }).toList();
      notifyListeners();
      return null;
    } catch (e) { return 'Gagal assign: $e'; }
  }

  Future<String?> adminRemoveAsdos(String classId, String asdosId) async {
    try {
      await _fs.removeAsdosFromClass(classId, asdosId);
      _classes = _classes.map((c) {
        if (c.id != classId) return c;
        return c.copyWith(asdosIds: c.asdosIds.where((id) => id != asdosId).toList());
      }).toList();
      notifyListeners();
      return null;
    } catch (e) { return 'Gagal hapus asdos: $e'; }
  }

  Future<String?> adminDeleteClass(String classId) async {
    try {
      await _fs.deleteClass(classId);
      _classes.removeWhere((c) => c.id == classId);
      notifyListeners();
      return null;
    } catch (e) { return 'Gagal hapus kelas: $e'; }
  }

  // ── Image picker ──────────────────────────────────────────────────────────

  Future<File?> pickImageFromCamera() async {
    try { return await _storage.pickFromCamera(); }
    catch (e) { _errorMessage = 'Tidak dapat mengakses kamera: $e'; notifyListeners(); return null; }
  }

  Future<File?> pickImageFromGallery() async {
    try { return await _storage.pickFromGallery(); }
    catch (e) { _errorMessage = 'Tidak dapat mengakses galeri: $e'; notifyListeners(); return null; }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _setLoading(bool v) { _loading = v; notifyListeners(); }
  void clearError() { _errorMessage = null; notifyListeners(); }

  Future<bool> _isOnline() async {
    final r = await Connectivity().checkConnectivity();
    return r != ConnectivityResult.none;
  }

  ActivityStats _computeStats(List<ActivityModel> l) => ActivityStats(
    total: l.length,
    approved: l.where((a) => a.status == ActivityStatus.approved).length,
    pending:  l.where((a) => a.status == ActivityStatus.pending).length,
    rejected: l.where((a) => a.status == ActivityStatus.rejected).length,
  );
}