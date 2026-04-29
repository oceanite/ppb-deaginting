import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/local_cache.dart';
import '../services/firestore_service.dart';
//import '../models/models.dart';

/// Sinkronisasi offline-first: cache SQLite ↔ Firestore
class SyncService {
  final _cache = LocalCache.instance;
  final _fs = FirestoreService();

  void startListening() {
    Connectivity().onConnectivityChanged.listen((result) { // 'result' is a single object
      final online = result != ConnectivityResult.none;
      if (online) _syncPending();
    });
  }

  Future<void> _syncPending() async {
    // Placeholder: sync lokal → Firestore jika ada antrian
  }

  /// Tarik data terbaru dari Firestore ke cache lokal
  Future<void> initialSync(String asdosId) async {
    try {
      final classes = await _fs.getClassesByAsdos(asdosId);
      await _cache.cacheClasses(classes);

      final activities = await _fs.getActivitiesByAsdos(asdosId);
      await _cache.cacheActivities(activities);
    } catch (_) {
      // Gagal sync → tetap pakai cache lokal
    }
  }

  Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}