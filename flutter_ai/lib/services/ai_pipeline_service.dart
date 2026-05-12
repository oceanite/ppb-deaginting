// lib/services/ai_pipeline_service.dart
//
// Orkestrasi dua tahap — seluruhnya via Groq (satu API key):
//   Tahap 1: File audio → Groq Whisper API → teks transkrip
//   Tahap 2: Teks → Groq LLM (Llama 3.3 70B) → EmpathyMapData (JSON)
//
// Daftar Groq API key gratis di: https://console.groq.com
// Tidak perlu kartu kredit.
//
// api-keys.json (untuk --dart-define-from-file):
// {
//   "GROQ_KEY": "gsk_xxxxxxxxxxxx"
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/empathy_map_data.dart';

class AiPipelineService {
  static const String _groqKey =
      String.fromEnvironment('GROQ_KEY', defaultValue: '');

  // Groq endpoints — keduanya pakai format OpenAI-compatible
  static const String _whisperUrl =
      'https://api.groq.com/openai/v1/audio/transcriptions';
  static const String _llmUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  // ── Public API ──

  Future<AiPipelineResult> analyze(String audioPath) async {
    _assertKeySet();
    final transcript = await _transcribe(audioPath);
    final empathyMap = await _analyzeEmpathy(transcript);
    return AiPipelineResult(transcript: transcript, empathyMapData: empathyMap);
  }

  // ── Tahap 1: Speech-to-Text via Groq Whisper ──

  Future<String> _transcribe(String audioPath) async {
    final file = File(audioPath);
    if (!await file.exists()) {
      throw AiPipelineException('File audio tidak ditemukan: $audioPath');
    }

    final request = http.MultipartRequest('POST', Uri.parse(_whisperUrl))
      ..headers['Authorization'] = 'Bearer $_groqKey'
      ..fields['model'] = 'whisper-large-v3-turbo'
      ..fields['language'] = 'id'
      ..fields['response_format'] = 'text'
      ..files.add(await http.MultipartFile.fromPath('file', audioPath));

    final streamed = await request.send().timeout(
      const Duration(seconds: 60),
      onTimeout: () => throw AiPipelineException('Groq Whisper timeout'),
    );

    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw AiPipelineException(
        'Groq Whisper error ${response.statusCode}: ${response.body}',
      );
    }

    final transcript = response.body.trim();
    if (transcript.isEmpty) {
      throw AiPipelineException(
        'Transkrip kosong — rekaman mungkin tidak terdeteksi suara',
      );
    }

    return transcript;
  }

  // ── Tahap 2: Empathy Map via Groq LLM (Llama 3.3 70B) ──

  Future<EmpathyMapData> _analyzeEmpathy(String transcript) async {
    final body = jsonEncode({
      'model': 'llama-3.3-70b-versatile',
      'messages': [
        {'role': 'system', 'content': _systemPrompt},
        {'role': 'user', 'content': _buildPrompt(transcript)},
      ],
      'max_tokens': 1024,
      'temperature': 0.7,
    });

    final response = await http.post(
      Uri.parse(_llmUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_groqKey',
      },
      body: body,
    ).timeout(
      const Duration(seconds: 45),
      onTimeout: () => throw AiPipelineException('Groq LLM timeout'),
    );

    if (response.statusCode != 200) {
      throw AiPipelineException(
        'Groq LLM error ${response.statusCode}: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final rawText =
        decoded['choices'][0]['message']['content'] as String;

    return _parseEmpathyMapJson(rawText);
  }

  // ── Prompt ──

  static const String _systemPrompt = '''
Kamu adalah psikolog empatik yang membantu pengguna memahami perasaan mereka.
Analisis transkrip jurnal suara dan buat Peta Empati dalam Bahasa Indonesia.

ATURAN PENTING:
- Balas HANYA dengan JSON yang valid. Tidak ada teks lain, tidak ada markdown.
- Gunakan bahasa yang hangat, personal, dan tidak menghakimi.
- Setiap item dalam array adalah satu kalimat pendek (max 8 kata).
- dominant_emotion: 1-3 kata yang merangkum emosi utama.
- color_hex: warna yang merepresentasikan mood (gelap=berat, cerah=positif).

FORMAT JSON (ikuti persis):
{
  "dominant_emotion": "string",
  "color_hex": "#RRGGBB",
  "empathy_map": {
    "feelings": ["string", "string", "string"],
    "thoughts": ["string", "string", "string"],
    "pain_points": ["string", "string", "string"],
    "actions": ["string", "string", "string"]
  }
}
''';

  String _buildPrompt(String transcript) => '''
Berikut transkrip jurnal suara pengguna:

---
$transcript
---

Buat Peta Empati. Balas hanya dengan JSON, tanpa penjelasan apapun.
''';

  // ── JSON Parser ──

  EmpathyMapData _parseEmpathyMapJson(String rawText) {
    // Bersihkan jika model tetap membungkus dengan markdown
    final cleaned = rawText
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    late final Map<String, dynamic> json;
    try {
      json = jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      throw AiPipelineException(
        'Gagal parse JSON dari LLM.\nRaw: $cleaned',
      );
    }

    final empMap = json['empathy_map'] as Map<String, dynamic>;

    return EmpathyMapData(
      dominantEmotion: json['dominant_emotion'] as String? ?? 'Tidak diketahui',
      colorHex: _hexToColor(json['color_hex'] as String? ?? '#A8D8EA'),
      empathyMap: EmpathyMap(
        feelings: _asList(empMap['feelings']),
        thoughts: _asList(empMap['thoughts']),
        painPoints: _asList(empMap['pain_points']),
        actions: _asList(empMap['actions']),
      ),
    );
  }

  List<String> _asList(dynamic value) {
    if (value is List) return value.cast<String>();
    return [];
  }

  Color _hexToColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  void _assertKeySet() {
    if (_groqKey.isEmpty) {
      throw AiPipelineException(
        'GROQ_KEY belum di-set.\n'
        'Jalankan: flutter run --dart-define-from-file=api-keys.json\n'
        'Daftar key gratis di: https://console.groq.com',
      );
    }
  }
}

// ─────────────────────────────────────────────
// RESULT & EXCEPTION
// ─────────────────────────────────────────────

class AiPipelineResult {
  final String transcript;
  final EmpathyMapData empathyMapData;

  const AiPipelineResult({
    required this.transcript,
    required this.empathyMapData,
  });
}

class AiPipelineException implements Exception {
  final String message;
  const AiPipelineException(this.message);

  @override
  String toString() => 'AiPipelineException: $message';
}