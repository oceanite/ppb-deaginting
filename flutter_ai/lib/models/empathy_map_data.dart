import 'dart:convert';
import 'dart:ui';

class EmpathyMapData {
  final String dominantEmotion;
  final Color colorHex;
  final EmpathyMap empathyMap;

  const EmpathyMapData({
    required this.dominantEmotion,
    required this.colorHex,
    required this.empathyMap,
  });
}

class EmpathyMap {
  final List<String> feelings;
  final List<String> thoughts;
  final List<String> painPoints;
  final List<String> actions;

  const EmpathyMap({
    required this.feelings,
    required this.thoughts,
    required this.painPoints,
    required this.actions,
  });

  /// Parse dari JSON string yang disimpan di kolom map_json SQLite.
  /// Contoh input: '{"feelings":["..."],"thoughts":["..."],...}'
  factory EmpathyMap.fromJsonString(String jsonString) {
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return EmpathyMap(
      feelings: _asList(map['feelings']),
      thoughts: _asList(map['thoughts']),
      painPoints: _asList(map['pain_points']),
      actions: _asList(map['actions']),
    );
  }

  static List<String> _asList(dynamic value) {
    if (value is List) return value.cast<String>();
    return [];
  }
}