// lib/models/journal_entry.dart
//
// Pure Dart model — TIDAK ada dependency ke Isar maupun Drift.
// Data persisten dikelola oleh Drift di lib/database/app_database.dart.
// File ini hanya dipakai untuk membawa data antar layer (UI ↔ Repository).
//
// CATATAN MIGRASI:
//   Versi lama pakai Isar (@collection, @embedded, @Index).
//   Semua anotasi Isar sudah DIHAPUS karena project sekarang pakai Drift.
//   File journal_entry.g.dart (generated Isar) juga bisa dihapus.

// ─── Enum AppState ────────────────────────────────────────────────────────────

enum AppState {
  home,       // layar awal, tombol mic
  recording,  // sedang merekam
  loading,    // AI sedang memproses
  result,     // peta empati ditampilkan
}

// ─── Sub-model: EmpathyQuadrant ───────────────────────────────────────────────
// Satu kuadran dari empathy map (Feelings / Thoughts / Pain Points / Actions).
// SEBELUMNYA pakai @embedded (Isar) — sekarang plain Dart class.

class EmpathyQuadrant {
  final String label;       // e.g. "Feelings"
  final String labelId;     // e.g. "Perasaan" (Bahasa Indonesia)
  final List<String> items; // butir-butir teks hasil analisis AI
  final String emoji;       // ikon dekoratif, e.g. "💛"

  const EmpathyQuadrant({
    this.label = '',
    this.labelId = '',
    this.items = const [],
    this.emoji = '',
  });

  /// Bangun dari map JSON yang dikirim AI.
  factory EmpathyQuadrant.fromJson(Map<String, dynamic> json) {
    return EmpathyQuadrant(
      label: json['label'] as String? ?? '',
      labelId: json['label_id'] as String? ?? '',
      items: List<String>.from(json['items'] as List? ?? []),
      emoji: json['emoji'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'label_id': labelId,
    'items': items,
    'emoji': emoji,
  };
}

// ─── Model utama: JournalEntry ────────────────────────────────────────────────
// Representasi in-memory dari satu sesi rekam + hasil analisis AI.
// SEBELUMNYA pakai @collection (Isar) — sekarang plain Dart class.

class JournalEntry {
  /// UUID v4, sama dengan id di tabel journals (Drift).
  final String id;

  /// Waktu sesi direkam (UTC).
  final DateTime createdAt;

  // ── Transkrip ──────────────────────────────────────────────────────────────

  /// Teks hasil transkripsi Whisper.
  final String transcript;

  /// Durasi rekaman audio dalam detik.
  final double durationSeconds;

  /// Path file audio lokal (nullable — bisa dihapus setelah diproses).
  final String? audioFilePath;

  // ── Analisis Empati ────────────────────────────────────────────────────────

  /// Emosi dominan, e.g. "Cemas", "Lega", "Bersemangat"
  final String dominantEmotion;

  /// Kode warna hex untuk emosi dominan, e.g. "#A8D8EA"
  final String colorHex;

  /// Empathy Map 4-kuadran.
  final EmpathyQuadrant feelings;
  final EmpathyQuadrant thoughts;
  final EmpathyQuadrant painPoints;
  final EmpathyQuadrant actions;

  /// Ringkasan naratif satu paragraf dari AI.
  final String summary;

  /// Skor intensitas emosi 0.0–1.0 (opsional, untuk chart historis).
  final double emotionIntensity;

  /// Tag bebas yang bisa ditambahkan pengguna di kemudian hari.
  final List<String> tags;

  // ── Metadata Pipeline ──────────────────────────────────────────────────────

  /// Model Whisper yang dipakai, e.g. "whisper-1"
  final String whisperModel;

  /// Model Claude yang dipakai, e.g. "claude-sonnet-4-20250514"
  final String claudeModel;

  /// Apakah audio sudah dihapus dari storage lokal demi privasi.
  final bool audioDeleted;

  // ─── Konstruktor ──────────────────────────────────────────────────────────

  const JournalEntry({
    required this.id,
    required this.createdAt,
    this.transcript = '',
    this.durationSeconds = 0,
    this.audioFilePath,
    this.dominantEmotion = '',
    this.colorHex = '#A8D8EA',
    this.feelings = const EmpathyQuadrant(),
    this.thoughts = const EmpathyQuadrant(),
    this.painPoints = const EmpathyQuadrant(),
    this.actions = const EmpathyQuadrant(),
    this.summary = '',
    this.emotionIntensity = 0.5,
    this.tags = const [],
    this.whisperModel = 'whisper-1',
    this.claudeModel = 'claude-sonnet-4-20250514',
    this.audioDeleted = false,
  });

  // ─── Factory: dari respons JSON AI ────────────────────────────────────────

  /// Buat JournalEntry dari JSON yang dikembalikan AiPipelineService.
  factory JournalEntry.fromAiResponse({
    required String id,
    required Map<String, dynamic> rawJson,
    required String transcript,
    required double durationSeconds,
    String? audioFilePath,
    String whisperModel = 'whisper-1',
    String claudeModel = 'claude-sonnet-4-20250514',
  }) {
    final empathyMap =
        rawJson['empathy_map'] as Map<String, dynamic>? ?? {};

    return JournalEntry(
      id: id,
      createdAt: DateTime.now().toUtc(),
      transcript: transcript,
      durationSeconds: durationSeconds,
      audioFilePath: audioFilePath,
      dominantEmotion: rawJson['dominant_emotion'] as String? ?? '',
      colorHex: rawJson['color_hex'] as String? ?? '#A8D8EA',
      feelings: EmpathyQuadrant.fromJson(
          empathyMap['feelings'] as Map<String, dynamic>? ?? {}),
      thoughts: EmpathyQuadrant.fromJson(
          empathyMap['thoughts'] as Map<String, dynamic>? ?? {}),
      painPoints: EmpathyQuadrant.fromJson(
          empathyMap['pain_points'] as Map<String, dynamic>? ?? {}),
      actions: EmpathyQuadrant.fromJson(
          empathyMap['actions'] as Map<String, dynamic>? ?? {}),
      summary: rawJson['summary'] as String? ?? '',
      emotionIntensity:
          (rawJson['emotion_intensity'] as num?)?.toDouble() ?? 0.5,
      whisperModel: whisperModel,
      claudeModel: claudeModel,
    );
  }

  // ─── Helper ────────────────────────────────────────────────────────────────

  /// Kembalikan keempat kuadran sebagai list berurutan untuk staggered card.
  List<EmpathyQuadrant> get allQuadrants =>
      [feelings, thoughts, painPoints, actions];

  /// Warna hex ke Color Flutter (tanpa package tambahan).
  /// Contoh: "#A8D8EA" → Color(0xFFA8D8EA)
  int get colorHexValue {
    final clean = colorHex.replaceAll('#', '');
    final padded = clean.length == 6 ? 'FF$clean' : clean;
    return int.tryParse(padded, radix: 16) ?? 0xFFA8D8EA;
  }

  /// Tanggal lokal yang sudah diformat, e.g. "12 Mei 2026"
  String get formattedDate {
    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final local = createdAt.toLocal();
    return '${local.day} ${bulan[local.month]} ${local.year}';
  }

  // ─── Dummy data untuk development / preview ───────────────────────────────

  static JournalEntry get dummy => JournalEntry.fromAiResponse(
        id: 'dummy-preview-001',
        transcript:
            'Hari ini saya merasa campur aduk. Di satu sisi saya excited '
            'dengan proyek baru, tapi di sisi lain saya khawatir deadline '
            'terlalu mepet dan saya takut tidak bisa memenuhi ekspektasi tim.',
        durationSeconds: 47.3,
        rawJson: {
          'dominant_emotion': 'Cemas-Antusias',
          'color_hex': '#B8D4E8',
          'emotion_intensity': 0.68,
          'summary':
              'Kamu sedang berada di persimpangan antara semangat dan kekhawatiran. '
              'Energimu untuk proyek ini nyata, namun rasa cemas soal tenggat '
              'waktu menutupinya. Ini tanda kamu peduli dan berani.',
          'empathy_map': {
            'feelings': {
              'label': 'Feelings',
              'label_id': 'Perasaan',
              'emoji': '💛',
              'items': [
                'Excited tapi cemas secara bersamaan',
                'Takut mengecewakan tim',
                'Bangga bisa dipercaya proyek ini',
              ],
            },
            'thoughts': {
              'label': 'Thoughts',
              'label_id': 'Pikiran',
              'emoji': '🌊',
              'items': [
                '"Apakah saya cukup kompeten?"',
                '"Deadline ini terlalu ketat"',
                '"Saya harus buat rencana sekarang"',
              ],
            },
            'pain_points': {
              'label': 'Pain Points',
              'label_id': 'Hambatan',
              'emoji': '🌧',
              'items': [
                'Konflik antara ambisi dan kapasitas waktu',
                'Tekanan ekspektasi eksternal',
                'Ketidakpastian hasil akhir',
              ],
            },
            'actions': {
              'label': 'Actions',
              'label_id': 'Tindakan',
              'emoji': '🌱',
              'items': [
                'Pecah deadline menjadi milestone kecil',
                'Komunikasi terbuka dengan tim soal kapasitas',
                'Luangkan 5 menit refleksi tiap pagi',
              ],
            },
          },
        },
      );
}