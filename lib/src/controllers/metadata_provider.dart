import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:metalink/metalink.dart';

import '../models/link_preview_data.dart';

/// Provider for link metadata with integration with MetaLink's caching system
class MetadataProvider extends ChangeNotifier {
  /// Creates a [MetadataProvider] with a pre-initialized MetaLink instance
  MetadataProvider._({
    required MetaLink metaLink,
  }) : _metaLink = metaLink;

  /// Factory constructor that creates a [MetadataProvider] with default settings
  ///
  /// This creates a non-cached instance that's immediately available
  factory MetadataProvider({
    Duration cacheDuration = const Duration(hours: 24),
    bool enableCache = true,
  }) {
    // Start with a non-cached instance for immediate use
    final metaLink = MetaLink.create();

    final provider = MetadataProvider._(metaLink: metaLink);

    // If caching is enabled, initialize a cached version and replace the initial one
    if (enableCache) {
      MetaLink.createWithCache(cacheDuration: cacheDuration)
          .then((cachedMetaLink) {
        provider._replaceMetaLink(cachedMetaLink);
      });
    }

    return provider;
  }

  /// Factory constructor that creates a [MetadataProvider] with a provided MetaLink instance
  factory MetadataProvider.withMetaLink(MetaLink metaLink) {
    return MetadataProvider._(metaLink: metaLink);
  }

  /// Asynchronously creates a [MetadataProvider] with caching enabled
  static Future<MetadataProvider> createWithCache({
    Duration cacheDuration = const Duration(hours: 24),
  }) async {
    final metaLink =
        await MetaLink.createWithCache(cacheDuration: cacheDuration);
    return MetadataProvider._(metaLink: metaLink);
  }

  /// Internal MetaLink instance for metadata extraction
  MetaLink _metaLink;

  /// A map tracking currently loading URLs to avoid duplicate requests
  final Map<String, Completer<LinkPreviewData>> _loadingUrls = {};

  /// In-memory cache for quick access (separate from MetaLink's cache)
  final Map<String, LinkPreviewData> _uiCache = {};

  /// Replaces the internal MetaLink instance
  void _replaceMetaLink(MetaLink newMetaLink) {
    final oldMetaLink = _metaLink;
    _metaLink = newMetaLink;
    oldMetaLink.dispose();
  }

  /// Loads metadata for the given URL, using MetaLink's cache if enabled
  Future<LinkPreviewData> getMetadata(String url,
      {bool forceRefresh = false}) async {
    if (url.isEmpty) {
      throw ArgumentError('URL cannot be empty');
    }

    // Normalize the URL by removing trailing slash
    final normalizedUrl =
        url.endsWith('/') ? url.substring(0, url.length - 1) : url;

    // If this URL is already being loaded, wait for the result
    if (_loadingUrls.containsKey(normalizedUrl)) {
      return _loadingUrls[normalizedUrl]!.future;
    }

    // Check UI memory cache first if not forcing refresh
    if (!forceRefresh && _uiCache.containsKey(normalizedUrl)) {
      return _uiCache[normalizedUrl]!;
    }

    // Create a completer to track this URL's loading state
    final completer = Completer<LinkPreviewData>();
    _loadingUrls[normalizedUrl] = completer;

    try {
      // Fetch metadata (MetaLink will handle its own caching)
      final metadata = await _metaLink.extract(
        normalizedUrl,
        skipCache: forceRefresh,
      );

      final previewData = LinkPreviewData.fromMetadata(metadata);

      // Update UI memory cache
      _uiCache[normalizedUrl] = previewData;

      completer.complete(previewData);
      _loadingUrls.remove(normalizedUrl);
      return previewData;
    } catch (e) {
      _loadingUrls.remove(normalizedUrl);
      completer.completeError(e);
      rethrow;
    }
  }

  /// Gets data for multiple URLs in parallel
  Future<List<LinkPreviewData>> getMultipleMetadata(
    List<String> urls, {
    bool forceRefresh = false,
    int concurrentRequests = 3,
  }) async {
    if (urls.isEmpty) {
      return [];
    }

    final results = <LinkPreviewData>[];

    // Process in batches to limit concurrent requests
    for (var i = 0; i < urls.length; i += concurrentRequests) {
      final end = (i + concurrentRequests < urls.length)
          ? i + concurrentRequests
          : urls.length;
      final batch = urls.sublist(i, end);

      // Process batch in parallel
      final batchResults = await Future.wait(
        batch.map((url) => getMetadata(url, forceRefresh: forceRefresh)),
      );

      results.addAll(batchResults);
    }

    return results;
  }

  /// Clear the memory cache
  /// Note: This only clears the UI cache, not MetaLink's internal cache
  void clearMemoryCache() {
    _uiCache.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _metaLink.dispose();
    super.dispose();
  }
}
