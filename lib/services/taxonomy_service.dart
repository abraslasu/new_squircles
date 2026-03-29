import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the Taxonomy Service.
final taxonomyServiceProvider = Provider<TaxonomyService>((ref) {
  return TaxonomyService();
});

/// A service to load and lookup semantic tags for SVG icons based on the raw_taxonomy.json file.
class TaxonomyService {
  /// Maps a filename (e.g., "fi-rr-plane.svg") to a list of tags (e.g., ["flight", "airport", ...])
  Map<String, List<String>> _taxonomyMap = {};
  bool _isLoaded = false;

  /// Loads the taxonomy JSON file from assets into memory.
  /// This should be called once during app initialization.
  Future<void> loadTaxonomy() async {
    if (_isLoaded) return;

    try {
      final jsonString = await rootBundle.loadString('assets/taxonomy/raw_taxonomy.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);

      for (var item in jsonList) {
        if (item is Map<String, dynamic>) {
          final filename = item['filename'] as String?;
          final tags = (item['tags'] as List<dynamic>?)?.cast<String>();

          if (filename != null && tags != null) {
            _taxonomyMap[filename] = tags;
          }
        }
      }
      _isLoaded = true;
      print('✅ TaxonomyService: Loaded ${_taxonomyMap.length} icon mappings.');
    } catch (e) {
      print('❌ TaxonomyService: Failed to load raw_taxonomy.json: $e');
    }
  }

  /// Looks up the tags for a given full asset path.
  /// e.g., "assets/icons/fi-rr-plane.svg" -> ["plane", "flight", "airport", "take-off", ...]
  List<String> getTagsForIconPath(String fullPath) {
    if (!_isLoaded) {
      print('⚠️ TaxonomyService: Warning - taxonomy not loaded yet.');
      return [];
    }

    // Extract just the filename from the full asset path
    // e.g., "assets/icons/fi-rr-plane.svg" -> "fi-rr-plane.svg"
    final filename = fullPath.split('/').last;

    // Return the tags or an empty list if not found
    return _taxonomyMap[filename] ?? [];
  }

  /// Formats the icon selection into a rich text string for the LLM prompt.
  /// Example Output:
  /// - fi-rr-plane.svg (Tags: plane, flight, airport, take-off, landing, travel, transport)
  String getRichTextForIcons(List<String> iconPaths) {
    if (iconPaths.isEmpty) return "No icons selected.";

    final buffer = StringBuffer();
    for (final path in iconPaths) {
      final filename = path.split('/').last;
      final tags = getTagsForIconPath(path);
      
      if (tags.isNotEmpty) {
        buffer.writeln('- $filename (Tags: ${tags.join(', ')})');
      } else {
        buffer.writeln('- $filename (Tags: Unknown)');
      }
    }
    return buffer.toString();
  }
}
