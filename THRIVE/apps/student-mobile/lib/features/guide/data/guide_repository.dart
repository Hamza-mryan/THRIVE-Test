import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/thrive_api.dart';

class GuideResource {
  const GuideResource({
    required this.id,
    required this.slug,
    required this.titleAr,
    required this.titleEn,
    required this.summaryAr,
    required this.summaryEn,
    required this.bodyAr,
    required this.bodyEn,
    required this.category,
    required this.source,
    required this.version,
    required this.isDemo,
    required this.published,
    this.reviewedAtUtc,
  });
  final String id;
  final String slug;
  final String titleAr;
  final String titleEn;
  final String summaryAr;
  final String summaryEn;
  final String bodyAr;
  final String bodyEn;
  final String category;
  final String source;
  final String version;
  final bool isDemo;
  final bool published;
  final DateTime? reviewedAtUtc;
  factory GuideResource.fromJson(Map<String, dynamic> json) => GuideResource(
    id: json['id'] as String,
    slug: json['slug'] as String,
    titleAr: json['titleAr'] as String,
    titleEn: json['titleEn'] as String,
    summaryAr: json['summaryAr'] as String,
    summaryEn: json['summaryEn'] as String,
    bodyAr: json['bodyAr'] as String,
    bodyEn: json['bodyEn'] as String,
    category: json['category'] as String,
    source: json['source'] as String,
    version: json['version'] as String,
    isDemo: json['isDemo'] as bool,
    published: json['published'] as bool,
    reviewedAtUtc: json['reviewedAtUtc'] == null
        ? null
        : DateTime.parse(json['reviewedAtUtc'] as String),
  );
  Map<String, Object?> toJson() => {
    'id': id,
    'slug': slug,
    'titleAr': titleAr,
    'titleEn': titleEn,
    'summaryAr': summaryAr,
    'summaryEn': summaryEn,
    'bodyAr': bodyAr,
    'bodyEn': bodyEn,
    'category': category,
    'source': source,
    'version': version,
    'isDemo': isDemo,
    'published': published,
    'reviewedAtUtc': reviewedAtUtc?.toIso8601String(),
  };
}

abstract interface class GuideCache {
  Future<List<GuideResource>> read();
  Future<void> write(List<GuideResource> resources);
}

/// This key contains public published guide text only. Never store session/health data here.
class PreferenceGuideCache implements GuideCache {
  static const key = 'thrive-test.public-guides.v1';
  @override
  Future<List<GuideResource>> read() async {
    final preferences = await SharedPreferences.getInstance();
    final data = preferences.getString(key);
    if (data == null) return [];
    try {
      return (jsonDecode(data) as List)
          .map((x) => GuideResource.fromJson(x as Map<String, dynamic>))
          .where((resource) => resource.published)
          .toList();
    } on FormatException {
      return [];
    }
  }

  @override
  Future<void> write(List<GuideResource> resources) async {
    final preferences = await SharedPreferences.getInstance();
    final success = await preferences.setString(
      key,
      jsonEncode(
        resources
            .where((resource) => resource.published)
            .map((resource) => resource.toJson())
            .toList(),
      ),
    );
    if (!success) throw const ApiFailure(ApiFailureKind.unavailable);
  }
}

class GuideLibrary {
  const GuideLibrary(this.resources, this.savedIds, this.offline);
  final List<GuideResource> resources;
  final Set<String> savedIds;
  final bool offline;
}

class GuideRepository {
  GuideRepository(this.api, this.cache);
  final ThriveApi api;
  final GuideCache cache;
  Future<GuideLibrary> savedLibrary() async {
    final resources = await cache.read();
    return GuideLibrary(resources, resources.map((x) => x.id).toSet(), true);
  }

  Future<GuideLibrary> library() async {
    final saved = await cache.read();
    try {
      final resources =
          (await api.request('GET', '/api/v1/guide/resources') as List)
              .map((x) => GuideResource.fromJson(x as Map<String, dynamic>))
              .toList();
      // Explicitly saved content remains visible after temporary removal from the live listing.
      final merged = {
        for (final resource in saved) resource.id: resource,
        for (final resource in resources) resource.id: resource,
      };
      return GuideLibrary(
        merged.values.toList(),
        saved.map((x) => x.id).toSet(),
        false,
      );
    } on ApiFailure catch (error) {
      if (saved.isEmpty || error.kind == ApiFailureKind.unauthorized) rethrow;
      return GuideLibrary(saved, saved.map((x) => x.id).toSet(), true);
    }
  }

  Future<bool> isSaved(String id) async =>
      (await cache.read()).any((x) => x.id == id);
  Future<void> save(GuideResource resource) async {
    if (!resource.published) throw const ApiFailure(ApiFailureKind.invalid);
    final current = await cache.read();
    await cache.write([...current.where((x) => x.id != resource.id), resource]);
  }

  Future<void> remove(String id) async =>
      cache.write((await cache.read()).where((x) => x.id != id).toList());
}
