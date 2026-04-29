import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/models.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ── TEST MODE ──────────────────────────────────────────────────────────────
  // Set ke TRUE untuk test — notif muncul 10 detik setelah login
  // Set ke FALSE untuk production — notif muncul sesuai jadwal asli
  static const bool _testMode = true;

  // ── Channels ───────────────────────────────────────────────────────────────

  static const _chClassReminder = AndroidNotificationChannel(
    'class_reminder', 'Pengingat Kelas',
    description: 'Notifikasi 30 menit sebelum kelas dimulai.',
    importance: Importance.high,
    enableVibration: true,
    playSound: true,
  );

  static const _chLogReminder = AndroidNotificationChannel(
    'log_reminder', 'Pengingat Log Aktivitas',
    description: 'Notifikasi 2 jam setelah kelas selesai jika log belum diisi.',
    importance: Importance.high,
    enableVibration: true,
    playSound: true,
  );

  static const _chStatus = AndroidNotificationChannel(
    'status_update', 'Update Status Log',
    description: 'Notifikasi saat dosen menyetujui atau menolak log.',
    importance: Importance.defaultImportance,
  );

  // ── Initialize ─────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) {
      print('[NOTIF] Already initialized, skip.');
      return;
    }

    print('[NOTIF] Initializing...');
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    print('[NOTIF] Timezone set to Asia/Jakarta');

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_chClassReminder);
    await androidPlugin?.createNotificationChannel(_chLogReminder);
    await androidPlugin?.createNotificationChannel(_chStatus);

    _initialized = true;
    print('[NOTIF] Initialized successfully.');
  }

  Future<void> requestPermissions() async {
    print('[NOTIF] Requesting permissions...');
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    print('[NOTIF] Android permission granted: $granted');
  }

  // ── rescheduleAll ──────────────────────────────────────────────────────────

  Future<void> rescheduleAll(List<ClassModel> classes) async {
    print('[NOTIF] rescheduleAll called. Classes count: ${classes.length}');
    await cancelAll();

    if (classes.isEmpty) {
      print('[NOTIF] No classes to schedule.');
      return;
    }

    if (_testMode) {
      // TEST MODE: jadwalkan notif 10 detik dari sekarang untuk semua kelas
      print('[NOTIF] TEST MODE ON — scheduling 10s test notifications.');
      for (final c in classes) {
        print('[NOTIF] Scheduling test notif for: ${c.name}');
        await _scheduleTestNotif(c);
      }
    } else {
      // PRODUCTION MODE: filter kelas hari ini
      final todayWeekday = DateTime.now().weekday;
      print('[NOTIF] Today weekday: $todayWeekday (1=Mon, 7=Sun)');

      for (final c in classes) {
        print('[NOTIF] Class "${c.name}" dayOfWeek=${c.dayOfWeek} '
            'match=${c.dayOfWeek == todayWeekday}');
        if (c.dayOfWeek == todayWeekday) {
          await scheduleClassReminder(
            classId: c.id,
            className: c.name,
            startTime: c.startTime,
          );
          await scheduleLogReminder(
            classId: c.id,
            className: c.name,
            endTime: c.endTime,
          );
        }
      }
    }

    // Verifikasi berapa notif yang terjadwal
    final pending = await getPending();
    print('[NOTIF] Total pending notifications: ${pending.length}');
    for (final p in pending) {
      print('[NOTIF]   → id=${p.id} title="${p.title}"');
    }
  }

  // ── Test mode helper ───────────────────────────────────────────────────────

  Future<void> _scheduleTestNotif(ClassModel c) async {
    final trigger = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
    print('[NOTIF] Test trigger time: $trigger');

    try {
      await _plugin.zonedSchedule(
        id: _classReminderId(c.id),
        title: '🔔 TEST: Kelas segera dimulai',
        body: '${c.name} — ini notif test (10 detik)',
        scheduledDate: trigger,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _chClassReminder.id, _chClassReminder.name,
            channelDescription: _chClassReminder.description,
            importance: Importance.high,
            priority: Priority.high,
            color: const Color(0xFF3C3489),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'test:${c.id}',
      );
      print('[NOTIF] Test notif scheduled OK for "${c.name}"');
    } catch (e) {
      print('[NOTIF] ERROR scheduling test notif: $e');
    }
  }

  // ── 1. Pengingat 30 menit sebelum kelas ───────────────────────────────────

  Future<void> scheduleClassReminder({
    required String classId,
    required String className,
    required String startTime,
    DateTime? classDate,
  }) async {
    if (!_initialized) {
      print('[NOTIF] scheduleClassReminder: NOT initialized, skip.');
      return;
    }

    final trigger = _triggerTimeBefore(
      startTime, classDate ?? DateTime.now(), const Duration(minutes: 30));

    print('[NOTIF] scheduleClassReminder "$className"');
    print('[NOTIF]   startTime=$startTime trigger=$trigger now=${DateTime.now()}');

    if (trigger == null) {
      print('[NOTIF]   SKIPPED: trigger sudah terlewat atau null');
      return;
    }

    try {
      await _plugin.zonedSchedule(
        id: _classReminderId(classId),
        title: '🔔 Kelas segera dimulai',
        body: '$className dimulai 30 menit lagi. Bersiaplah!',
        scheduledDate: trigger,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _chClassReminder.id, _chClassReminder.name,
            channelDescription: _chClassReminder.description,
            importance: Importance.high,
            priority: Priority.high,
            color: const Color(0xFF3C3489),
          ),
          iOS: const DarwinNotificationDetails(
            categoryIdentifier: 'class_reminder',
            sound: 'default',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'class_reminder:$classId',
      );
      print('[NOTIF]   Scheduled OK at $trigger');
    } catch (e) {
      print('[NOTIF]   ERROR: $e');
    }
  }

  // ── 2. Pengingat isi log 2 jam setelah kelas ──────────────────────────────

  Future<void> scheduleLogReminder({
    required String classId,
    required String className,
    required String endTime,
    DateTime? classDate,
  }) async {
    if (!_initialized) {
      print('[NOTIF] scheduleLogReminder: NOT initialized, skip.');
      return;
    }

    final trigger = _triggerTimeAfter(
      endTime, classDate ?? DateTime.now(), const Duration(hours: 2));

    print('[NOTIF] scheduleLogReminder "$className"');
    print('[NOTIF]   endTime=$endTime trigger=$trigger now=${DateTime.now()}');

    if (trigger == null) {
      print('[NOTIF]   SKIPPED: trigger sudah terlewat atau null');
      return;
    }

    try {
      await _plugin.zonedSchedule(
        id: _logReminderId(classId),
        title: '📋 Jangan lupa isi log!',
        body: 'Kelas $className selesai 2 jam lalu. Segera input aktivitas.',
        scheduledDate: trigger,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _chLogReminder.id, _chLogReminder.name,
            channelDescription: _chLogReminder.description,
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(
              'Kelas $className sudah selesai 2 jam lalu.\n'
              'Segera isi log aktivitas agar dosen dapat melakukan verifikasi.',
              summaryText: 'LogAsdos',
            ),
            color: const Color(0xFF3C3489),
          ),
          iOS: const DarwinNotificationDetails(
            categoryIdentifier: 'log_reminder',
            sound: 'default',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'log_reminder:$classId',
      );
      print('[NOTIF]   Scheduled OK at $trigger');
    } catch (e) {
      print('[NOTIF]   ERROR: $e');
    }
  }

  Future<void> cancelClassReminders(String classId) async {
    await _plugin.cancel(id: _classReminderId(classId));
    await _plugin.cancel(id: _logReminderId(classId));
  }

  // ── 3. Status approval/rejection ──────────────────────────────────────────

  Future<void> showApprovalNotification({
    required String activityId,
    required String className,
    required String dosenName,
  }) async {
    if (!_initialized) return;
    print('[NOTIF] showApprovalNotification for "$className"');
    await _plugin.show(
      id: _approveId(activityId),
      title: '✅ Log disetujui',
      body: 'Log $className kamu disetujui oleh $dosenName.',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _chStatus.id, _chStatus.name,
          importance: Importance.defaultImportance,
          color: const Color(0xFF3B6D11),
        ),
      ),
      payload: 'approved:$activityId',
    );
  }

  Future<void> showRejectionNotification({
    required String activityId,
    required String className,
    required String dosenName,
    String? reason,
  }) async {
    if (!_initialized) return;
    print('[NOTIF] showRejectionNotification for "$className"');
    await _plugin.show(
      id: _rejectId(activityId),
      title: '⚠️ Log perlu diperbaiki',
      body: reason != null
          ? 'Log $className ditolak: $reason'
          : 'Log $className ditolak oleh $dosenName.',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _chStatus.id, _chStatus.name,
          importance: Importance.defaultImportance,
          color: const Color(0xFFA32D2D),
          styleInformation: reason != null
              ? BigTextStyleInformation(
                  'Log $className ditolak oleh $dosenName.\nAlasan: $reason')
              : null,
        ),
      ),
      payload: 'rejected:$activityId',
    );
  }

  // ── Utils ──────────────────────────────────────────────────────────────────

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    print('[NOTIF] All notifications cancelled.');
  }

  Future<List<PendingNotificationRequest>> getPending() =>
      _plugin.pendingNotificationRequests();

  // ── Private helpers ────────────────────────────────────────────────────────

  void _onNotificationTap(NotificationResponse resp) {
    print('[NOTIF] Tapped: payload=${resp.payload}');
  }

  tz.TZDateTime? _triggerTimeBefore(String time, DateTime base, Duration before) {
    final dt = _parseTime(time, base);
    if (dt == null) return null;
    final trigger = dt.subtract(before);
    if (trigger.isBefore(DateTime.now())) return null;
    return tz.TZDateTime.from(trigger, tz.local);
  }

  tz.TZDateTime? _triggerTimeAfter(String time, DateTime base, Duration after) {
    final dt = _parseTime(time, base);
    if (dt == null) return null;
    final trigger = dt.add(after);
    if (trigger.isBefore(DateTime.now())) return null;
    return tz.TZDateTime.from(trigger, tz.local);
  }

  DateTime? _parseTime(String time, DateTime base) {
    final parts = time.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return DateTime(base.year, base.month, base.day, h, m);
  }

  int _classReminderId(String id) => id.hashCode.abs() % 49999;
  int _logReminderId(String id)   => id.hashCode.abs() % 49999 + 50000;
  int _approveId(String id)       => id.hashCode.abs() % 49999 + 100000;
  int _rejectId(String id)        => id.hashCode.abs() % 49999 + 150000;
}