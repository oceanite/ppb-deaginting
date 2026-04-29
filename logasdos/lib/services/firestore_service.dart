import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users      => _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _classes    => _db.collection('classes');
  CollectionReference<Map<String, dynamic>> get _activities => _db.collection('activities');

  // ── Users ─────────────────────────────────────────────────────────────────

  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc.data()!, uid);
  }

  Future<List<UserModel>> getAllUsers() async {
    final snap = await _users.orderBy('name').get();
    return snap.docs.map((d) => UserModel.fromFirestore(d.data(), d.id)).toList();
  }

  Future<List<UserModel>> getUsersByRole(UserRole role) async {
    final snap = await _users
        .where('role', isEqualTo: role.name)
        .orderBy('name')
        .get();
    return snap.docs.map((d) => UserModel.fromFirestore(d.data(), d.id)).toList();
  }

  Future<void> updateUser(String uid, {String? name, UserRole? role}) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name.trim();
    if (role != null) data['role'] = role.name;
    if (data.isEmpty) return;
    await _users.doc(uid).update(data);
  }

  Future<void> deleteUserFromFirestore(String uid) async {
    await _users.doc(uid).delete();
  }

  Future<List<UserModel>> getAsdosByDosen(String dosenId) async {
    final classSnap = await _classes.where('dosenId', isEqualTo: dosenId).get();
    final asdosIds = <String>{};
    for (final doc in classSnap.docs) {
      asdosIds.addAll(List<String>.from(doc.data()['asdosIds'] as List? ?? []));
    }
    if (asdosIds.isEmpty) return [];
    final results = <UserModel>[];
    for (final chunk in _chunk(asdosIds.toList(), 10)) {
      final snap = await _users.where(FieldPath.documentId, whereIn: chunk).get();
      results.addAll(snap.docs.map((d) => UserModel.fromFirestore(d.data(), d.id)));
    }
    return results;
  }

  // ── Classes ───────────────────────────────────────────────────────────────

  Future<List<ClassModel>> getAllClasses() async {
    final snap = await _classes.orderBy('name').get();
    return snap.docs.map((d) => ClassModel.fromFirestore(d.data(), d.id)).toList();
  }

  Future<List<ClassModel>> getClassesByAsdos(String asdosId) async {
    try {
      // Query dengan composite index: asdosIds (array) + dayOfWeek + startTime
      final snap = await _classes
          .where('asdosIds', arrayContains: asdosId)
          .orderBy('dayOfWeek')
          .orderBy('startTime')
          .get();
      return snap.docs.map((d) => ClassModel.fromFirestore(d.data(), d.id)).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        // Index belum siap — fallback: filter tanpa orderBy, sort di client
        final snap = await _classes
            .where('asdosIds', arrayContains: asdosId)
            .get();
        final list = snap.docs
            .map((d) => ClassModel.fromFirestore(d.data(), d.id))
            .toList();
        list.sort((a, b) {
          final day = a.dayOfWeek.compareTo(b.dayOfWeek);
          return day != 0 ? day : a.startTime.compareTo(b.startTime);
        });
        return list;
      }
      rethrow;
    }
  }

  Future<List<ClassModel>> getClassesByDosen(String dosenId) async {
    try {
      // Query dengan composite index: dosenId + dayOfWeek + startTime
      final snap = await _classes
          .where('dosenId', isEqualTo: dosenId)
          .orderBy('dayOfWeek')
          .orderBy('startTime')
          .get();
      return snap.docs.map((d) => ClassModel.fromFirestore(d.data(), d.id)).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        // Fallback tanpa orderBy
        final snap = await _classes
            .where('dosenId', isEqualTo: dosenId)
            .get();
        final list = snap.docs
            .map((d) => ClassModel.fromFirestore(d.data(), d.id))
            .toList();
        list.sort((a, b) {
          final day = a.dayOfWeek.compareTo(b.dayOfWeek);
          return day != 0 ? day : a.startTime.compareTo(b.startTime);
        });
        return list;
      }
      rethrow;
    }
  }

  Future<ClassModel?> getClass(String id) async {
    final doc = await _classes.doc(id).get();
    if (!doc.exists) return null;
    return ClassModel.fromFirestore(doc.data()!, id);
  }

  Future<String> createClass(ClassModel c) async {
    final ref = await _classes.add(c.toFirestore());
    return ref.id;
  }

  Future<void> updateClass(ClassModel c) async {
    await _classes.doc(c.id).set(c.toFirestore(), SetOptions(merge: true));
  }

  Future<void> addAsdosToClass(String classId, String asdosId) async {
    await _classes.doc(classId).update({
      'asdosIds': FieldValue.arrayUnion([asdosId]),
    });
  }

  Future<void> removeAsdosFromClass(String classId, String asdosId) async {
    await _classes.doc(classId).update({
      'asdosIds': FieldValue.arrayRemove([asdosId]),
    });
  }

  Future<void> deleteClass(String classId) async {
    await _classes.doc(classId).delete();
  }

  // ── Activities ────────────────────────────────────────────────────────────

  Future<String> insertActivity(ActivityModel a) async {
    final ref = await _activities.add(a.toFirestore());
    return ref.id;
  }

  Future<List<ActivityModel>> getActivitiesByAsdos(String asdosId) async {
    try {
      // Query dengan composite index: asdosId + createdAt DESC
      final snap = await _activities
          .where('asdosId', isEqualTo: asdosId)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((d) => ActivityModel.fromFirestore(d.data(), d.id))
          .toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        // Fallback: filter tanpa orderBy, sort di client
        final snap = await _activities
            .where('asdosId', isEqualTo: asdosId)
            .get();
        final list = snap.docs
            .map((d) => ActivityModel.fromFirestore(d.data(), d.id))
            .toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      }
      rethrow;
    }
  }

  Future<List<ActivityModel>> getActivitiesByDosen(String dosenId) async {
    final classSnap = await _classes.where('dosenId', isEqualTo: dosenId).get();
    final classIds = classSnap.docs.map((d) => d.id).toList();
    if (classIds.isEmpty) return [];
    final results = <ActivityModel>[];
    for (final chunk in _chunk(classIds, 10)) {
      try {
        final snap = await _activities
            .where('classId', whereIn: chunk)
            .orderBy('createdAt', descending: true)
            .get();
        results.addAll(snap.docs.map((d) => ActivityModel.fromFirestore(d.data(), d.id)));
      } on FirebaseException catch (e) {
        if (e.code == 'failed-precondition') {
          final snap = await _activities
              .where('classId', whereIn: chunk)
              .get();
          results.addAll(snap.docs.map((d) => ActivityModel.fromFirestore(d.data(), d.id)));
        } else {
          rethrow;
        }
      }
    }
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  Future<List<ActivityModel>> getActivitiesByDosenAndAsdos(
      String dosenId, String asdosId) async {
    final classSnap = await _classes.where('dosenId', isEqualTo: dosenId).get();
    final classIds = classSnap.docs.map((d) => d.id).toList();
    if (classIds.isEmpty) return [];
    final results = <ActivityModel>[];
    for (final chunk in _chunk(classIds, 10)) {
      try {
        final snap = await _activities
            .where('classId', whereIn: chunk)
            .where('asdosId', isEqualTo: asdosId)
            .orderBy('createdAt', descending: true)
            .get();
        results.addAll(snap.docs.map((d) => ActivityModel.fromFirestore(d.data(), d.id)));
      } on FirebaseException catch (e) {
        if (e.code == 'failed-precondition') {
          final snap = await _activities
              .where('classId', whereIn: chunk)
              .where('asdosId', isEqualTo: asdosId)
              .get();
          results.addAll(snap.docs.map((d) => ActivityModel.fromFirestore(d.data(), d.id)));
        } else {
          rethrow;
        }
      }
    }
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  Future<List<ActivityModel>> getAllActivities({int limit = 100}) async {
    final snap = await _activities
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => ActivityModel.fromFirestore(d.data(), d.id)).toList();
  }

  Future<void> updateActivityStatus({
    required String activityId,
    required ActivityStatus status,
    String? rejectReason,
  }) async {
    await _activities.doc(activityId).update({
      'status': status.name,
      if (rejectReason != null) 'rejectReason': rejectReason,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> bulkUpdateStatus({
    required List<String> ids,
    required ActivityStatus status,
  }) async {
    const batchSize = 400;
    for (int i = 0; i < ids.length; i += batchSize) {
      final batch = _db.batch();
      for (final id in ids.skip(i).take(batchSize)) {
        batch.update(_activities.doc(id), {
          'status': status.name,
          'reviewedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }
  }

  // ── Stats ─────────────────────────────────────────────────────────────────

  Future<ActivityStats> getStats(String asdosId) async {
    final snap = await _activities
        .where('asdosId', isEqualTo: asdosId)
        .get();
    int approved = 0, pending = 0, rejected = 0;
    for (final d in snap.docs) {
      switch (d.data()['status'] as String?) {
        case 'approved': approved++; break;
        case 'pending':  pending++;  break;
        case 'rejected': rejected++; break;
      }
    }
    return ActivityStats(
        total: snap.size,
        approved: approved,
        pending: pending,
        rejected: rejected);
  }

  Future<AdminStats> getAdminStats() async {
    final usersSnap      = await _users.get();
    final classesSnap    = await _classes.get();
    final activitiesSnap = await _activities.get();

    int totalDosen = 0, totalAsdos = 0, pending = 0, approved = 0;
    for (final d in usersSnap.docs) {
      final role = d.data()['role'] as String?;
      if (role == 'dosen') totalDosen++;
      if (role == 'asdos') totalAsdos++;
    }
    for (final d in activitiesSnap.docs) {
      final status = d.data()['status'] as String?;
      if (status == 'pending') pending++;
      if (status == 'approved') approved++;
    }

    return AdminStats(
      totalUsers: usersSnap.size,
      totalDosen: totalDosen,
      totalAsdos: totalAsdos,
      totalClasses: classesSnap.size,
      totalActivities: activitiesSnap.size,
      pendingActivities: pending,
      approvedActivities: approved,
    );
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  List<List<T>> _chunk<T>(List<T> list, int size) {
    final chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += size) {
      chunks.add(list.skip(i).take(size).toList());
    }
    return chunks;
  }
}  