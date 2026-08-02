import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/render96_model.dart';

class Render96Datasource {
  List<Render96Model>? _cache;

  Future<List<Render96Model>> getAll() async {
    if (_cache != null) return _cache!;

    final raw = await rootBundle.loadString('assets/db/render96.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final list = json['render96_mods'] as List<dynamic>;

    _cache = list
        .map((e) => Render96Model.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  void invalidateCache() {
    _cache = null;
  }
}
