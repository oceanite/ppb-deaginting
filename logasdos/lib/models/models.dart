enum UserRole { admin, dosen, asdos }
enum ActivityStatus { pending, approved, rejected }
enum ActivityCategory { mengajar, kuis, praktikum }
enum ClassMode { luring, daring }

// ── UserModel ─────────────────────────────────────────────────────────────────

class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  String get initials {
    final p = name.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isDosen => role == UserRole.dosen;
  bool get isAsdos => role == UserRole.asdos;

  factory UserModel.fromFirestore(Map<String, dynamic> d, String uid) => UserModel(
        uid: uid,
        name: d['name'] as String? ?? '',
        email: d['email'] as String? ?? '',
        role: _roleFromString(d['role'] as String? ?? 'asdos'),
      );

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'role': role.name,
      };

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
        uid: m['uid'] as String,
        name: m['name'] as String,
        email: m['email'] as String,
        role: _roleFromString(m['role'] as String? ?? 'asdos'),
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'role': role.name,
      };

  static UserRole _roleFromString(String s) => switch (s) {
        'admin' => UserRole.admin,
        'dosen' => UserRole.dosen,
        _ => UserRole.asdos,
      };
}

// ── ClassModel ────────────────────────────────────────────────────────────────

class ClassModel {
  final String id;
  final String name;
  final String dosenId;
  final String dosenName;
  final String startTime;
  final String endTime;
  final String room;
  final bool isOnline;
  final int dayOfWeek;
  final List<String> asdosIds;

  const ClassModel({
    required this.id,
    required this.name,
    required this.dosenId,
    required this.dosenName,
    required this.startTime,
    required this.endTime,
    required this.room,
    this.isOnline = false,
    this.dayOfWeek = 1,
    this.asdosIds = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory ClassModel.fromFirestore(Map<String, dynamic> d, String id) => ClassModel(
        id: id,
        name: d['name'] as String? ?? '',
        dosenId: d['dosenId'] as String? ?? '',
        dosenName: d['dosenName'] as String? ?? '',
        startTime: d['startTime'] as String? ?? '',
        endTime: d['endTime'] as String? ?? '',
        room: d['room'] as String? ?? '',
        isOnline: d['isOnline'] as bool? ?? false,
        dayOfWeek: d['dayOfWeek'] as int? ?? 1,
        asdosIds: List<String>.from(d['asdosIds'] as List? ?? []),
      );

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'dosenId': dosenId,
        'dosenName': dosenName,
        'startTime': startTime,
        'endTime': endTime,
        'room': room,
        'isOnline': isOnline,
        'dayOfWeek': dayOfWeek,
        'asdosIds': asdosIds,
      };

  factory ClassModel.fromMap(Map<String, dynamic> m) => ClassModel(
        id: m['id'] as String,
        name: m['name'] as String,
        dosenId: m['dosen_id'] as String,
        dosenName: m['dosen_name'] as String? ?? '',
        startTime: m['start_time'] as String,
        endTime: m['end_time'] as String,
        room: m['room'] as String,
        isOnline: (m['is_online'] as int?) == 1,
        dayOfWeek: m['day_of_week'] as int? ?? 1,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'dosen_id': dosenId,
        'dosen_name': dosenName,
        'start_time': startTime,
        'end_time': endTime,
        'room': room,
        'is_online': isOnline ? 1 : 0,
        'day_of_week': dayOfWeek,
      };

  ClassModel copyWith({
    String? id, String? name, String? dosenId, String? dosenName,
    String? startTime, String? endTime, String? room,
    bool? isOnline, int? dayOfWeek, List<String>? asdosIds,
  }) => ClassModel(
    id: id ?? this.id,
    name: name ?? this.name,
    dosenId: dosenId ?? this.dosenId,
    dosenName: dosenName ?? this.dosenName,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    room: room ?? this.room,
    isOnline: isOnline ?? this.isOnline,
    dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    asdosIds: asdosIds ?? this.asdosIds,
  );
}

// ── ActivityModel ─────────────────────────────────────────────────────────────

class ActivityModel {
  final String id;
  final String classId;
  final String className;
  final String asdosId;
  final String asdosName;
  final ActivityCategory category;
  final String description;
  final String? photoPath;
  final String? photoUrl;
  final ActivityStatus status;
  final ClassMode mode;
  final DateTime date;
  final String timeRange;
  final String? rejectReason;
  final DateTime createdAt;

  const ActivityModel({
    required this.id,
    required this.classId,
    required this.className,
    required this.asdosId,
    required this.asdosName,
    required this.category,
    required this.description,
    this.photoPath,
    this.photoUrl,
    required this.status,
    required this.mode,
    required this.date,
    required this.timeRange,
    this.rejectReason,
    required this.createdAt,
  });

  String get categoryLabel => switch (category) {
        ActivityCategory.mengajar => 'Mengajar',
        ActivityCategory.kuis => 'Kuis',
        ActivityCategory.praktikum => 'Praktikum',
      };

  String get statusLabel => switch (status) {
        ActivityStatus.pending => 'Pending',
        ActivityStatus.approved => 'Disetujui',
        ActivityStatus.rejected => 'Ditolak',
      };

  String? get displayPhoto => photoUrl ?? photoPath;
  bool get hasPhoto => displayPhoto != null && displayPhoto!.isNotEmpty;

  ActivityModel copyWith({
    String? id, String? classId, String? className,
    String? asdosId, String? asdosName,
    ActivityCategory? category, String? description,
    String? photoPath, String? photoUrl,
    ActivityStatus? status, ClassMode? mode,
    DateTime? date, String? timeRange,
    String? rejectReason, DateTime? createdAt,
  }) => ActivityModel(
    id: id ?? this.id, classId: classId ?? this.classId,
    className: className ?? this.className,
    asdosId: asdosId ?? this.asdosId,
    asdosName: asdosName ?? this.asdosName,
    category: category ?? this.category,
    description: description ?? this.description,
    photoPath: photoPath ?? this.photoPath,
    photoUrl: photoUrl ?? this.photoUrl,
    status: status ?? this.status,
    mode: mode ?? this.mode,
    date: date ?? this.date,
    timeRange: timeRange ?? this.timeRange,
    rejectReason: rejectReason ?? this.rejectReason,
    createdAt: createdAt ?? this.createdAt,
  );

  factory ActivityModel.fromFirestore(Map<String, dynamic> d, String id) =>
      ActivityModel(
        id: id,
        classId: d['classId'] as String? ?? '',
        className: d['className'] as String? ?? '',
        asdosId: d['asdosId'] as String? ?? '',
        asdosName: d['asdosName'] as String? ?? '',
        category: ActivityCategory.values.firstWhere(
          (e) => e.name == d['category'], orElse: () => ActivityCategory.mengajar),
        description: d['description'] as String? ?? '',
        photoUrl: d['photoUrl'] as String?,
        photoPath: d['photoPath'] as String?,
        status: ActivityStatus.values.firstWhere(
          (e) => e.name == d['status'], orElse: () => ActivityStatus.pending),
        mode: (d['isOnline'] as bool? ?? false) ? ClassMode.daring : ClassMode.luring,
        date: (d['date'] as dynamic)?.toDate() ?? DateTime.now(),
        timeRange: d['timeRange'] as String? ?? '',
        rejectReason: d['rejectReason'] as String?,
        createdAt: (d['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toFirestore() => {
        'classId': classId, 'className': className,
        'asdosId': asdosId, 'asdosName': asdosName,
        'category': category.name, 'description': description,
        'photoUrl': photoUrl, 'photoPath': photoPath,
        'status': status.name, 'isOnline': mode == ClassMode.daring,
        'date': date, 'timeRange': timeRange,
        'rejectReason': rejectReason, 'createdAt': createdAt,
      };

  factory ActivityModel.fromMap(Map<String, dynamic> m) => ActivityModel(
        id: m['id'] as String,
        classId: m['class_id'] as String,
        className: m['class_name'] as String? ?? '',
        asdosId: m['asdos_id'] as String,
        asdosName: m['asdos_name'] as String? ?? '',
        category: ActivityCategory.values.firstWhere(
          (e) => e.name == m['category'], orElse: () => ActivityCategory.mengajar),
        description: m['description'] as String,
        photoPath: m['photo_path'] as String?,
        photoUrl: m['photo_url'] as String?,
        status: ActivityStatus.values.firstWhere(
          (e) => e.name == m['status'], orElse: () => ActivityStatus.pending),
        mode: (m['is_online'] as int?) == 1 ? ClassMode.daring : ClassMode.luring,
        date: DateTime.parse(m['date'] as String),
        timeRange: m['time_range'] as String,
        rejectReason: m['reject_reason'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id, 'class_id': classId, 'class_name': className,
        'asdos_id': asdosId, 'asdos_name': asdosName,
        'category': category.name, 'description': description,
        'photo_path': photoPath, 'photo_url': photoUrl,
        'status': status.name, 'is_online': mode == ClassMode.daring ? 1 : 0,
        'date': date.toIso8601String(), 'time_range': timeRange,
        'reject_reason': rejectReason, 'created_at': createdAt.toIso8601String(),
      };
}

// ── Stats ─────────────────────────────────────────────────────────────────────

class ActivityStats {
  final int total, approved, pending, rejected;
  const ActivityStats({
    required this.total, required this.approved,
    required this.pending, required this.rejected,
  });
  double get approvalRate => total == 0 ? 0 : approved / total;
}

// ── Admin Dashboard Stats ─────────────────────────────────────────────────────

class AdminStats {
  final int totalUsers, totalDosen, totalAsdos;
  final int totalClasses, totalActivities;
  final int pendingActivities, approvedActivities;

  const AdminStats({
    required this.totalUsers, required this.totalDosen,
    required this.totalAsdos, required this.totalClasses,
    required this.totalActivities, required this.pendingActivities,
    required this.approvedActivities,
  });
}