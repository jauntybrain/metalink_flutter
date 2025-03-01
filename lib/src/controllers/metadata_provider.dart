import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:metalink/metalink.dart';

/// Provider for link metadata with integration with MetaLink's caching system
class MetadataProvider extends ChangeNotifier {
  /// Factory constructor that creates a [MetadataProvider] with a provided MetaLink instance
  factory MetadataProvider.withMetaLink(MetaLink metaLink) {
    return MetadataProvider._(metaLink: metaLink);
  }

  /// Creates a [MetadataProvider] with a pre-initialized MetaLink instance
  MetadataProvider._({
    required MetaLink metaLink,
  }) : _metaLink = metaLink;

  /// Factory constructor that creates a [MetadataProvider] with default settings
  ///
  /// This creates a non-cached instance that's immediately available
  factory MetadataProvider.create({
    http.Client? client,
    Duration timeout = const Duration(seconds: 10),
    String? userAgent,
    bool followRedirects = true,
    bool optimizeUrls = true,
    int maxRedirects = 5,
    bool analyzeImages = true,
    bool extractStructuredData = true,
    bool extractSocialMetrics = false,
    bool analyzeContent = false,
    String? proxyUrl,
  }) =>
      MetadataProvider._(
        metaLink: MetaLink.create(
          client: client,
          timeout: timeout,
          userAgent: userAgent ?? _getDefaultUserAgent(),
          followRedirects: followRedirects,
          optimizeUrls: optimizeUrls,
          maxRedirects: maxRedirects,
          analyzeImages: analyzeImages,
          extractStructuredData: extractStructuredData,
          extractSocialMetrics: extractSocialMetrics,
          analyzeContent: analyzeContent,
          proxyUrl: proxyUrl,
        ),
      );

  /// Asynchronously creates a [MetadataProvider] with caching enabled
  static Future<MetadataProvider> createWithCache({
    http.Client? client,
    Duration timeout = const Duration(seconds: 20),
    String? userAgent,
    Duration cacheDuration = const Duration(hours: 24),
    bool followRedirects = true,
    bool optimizeUrls = true,
    int maxRedirects = 5,
    bool analyzeImages = true,
    bool extractStructuredData = true,
    bool extractSocialMetrics = false,
    bool analyzeContent = false,
    String? proxyUrl,
  }) async {
    final metaLink = await MetaLink.createWithCache(
      client: client,
      timeout: timeout,
      userAgent: userAgent ?? _getDefaultUserAgent(),
      cacheDuration: cacheDuration,
      followRedirects: followRedirects,
      optimizeUrls: optimizeUrls,
      maxRedirects: maxRedirects,
      analyzeImages: analyzeImages,
      extractStructuredData: extractStructuredData,
      extractSocialMetrics: extractSocialMetrics,
      analyzeContent: analyzeContent,
      customCache: MetadataFlutterCacheFactory.getSharedInstance,
      proxyUrl: proxyUrl,
    );
    return MetadataProvider._(metaLink: metaLink);
  }

  /// Returns a default user agent string appropriate for the platform
  static String _getDefaultUserAgent() {
    if (kIsWeb) {
      return 'Mozilla/5.0 MetaLink Flutter Web Client';
    } else {
      return 'MetaLink Flutter Client';
    }
  }

  /// Internal MetaLink instance for metadata extraction
  MetaLink _metaLink;

  /// A map tracking currently loading URLs to avoid duplicate requests
  final Map<String, Completer<LinkMetadata>> _loadingUrls = {};

  /// In-memory cache for quick access (separate from MetaLink's cache)
  final Map<String, LinkMetadata> _uiCache = {};

  /// Loads metadata for the given URL, using MetaLink's cache if enabled
  Future<LinkMetadata> getMetadata(
    String url, {
    bool forceRefresh = false,
  }) async {
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
      final cachedData = _uiCache[normalizedUrl]!;

      // Check if the cached data contains useful information
      // If not valid, proceed to fetch fresh data
      if (cachedData.isValid) {
        return cachedData;
      }
    }

    // Create a completer to track this URL's loading state
    final completer = Completer<LinkMetadata>();
    _loadingUrls[normalizedUrl] = completer;

    try {
      // Fetch metadata (MetaLink will handle its own caching)
      LinkMetadata previewData;

      try {
        previewData = await _metaLink.extract(
          normalizedUrl,
          skipCache: forceRefresh,
        );
      } catch (e) {
        // Handle web-specific errors with more informative messages
        if (kIsWeb && e.toString().contains('Failed to fetch')) {
          throw Exception(
              'CORS error: Unable to fetch metadata for $normalizedUrl. '
              'This is a browser security restriction when running on the web platform. '
              'Please use a CORS proxy in your application.');
        }
        rethrow;
      }

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
  Future<List<LinkMetadata>> getMultipleMetadata(
    List<String> urls, {
    bool forceRefresh = false,
    int concurrentRequests = 3,
  }) async {
    if (urls.isEmpty) {
      return [];
    }

    final results = <LinkMetadata>[];

    // Process in batches to limit concurrent requests
    for (var i = 0; i < urls.length; i += concurrentRequests) {
      final end = (i + concurrentRequests < urls.length)
          ? i + concurrentRequests
          : urls.length;
      final batch = urls.sublist(i, end);

      // Process batch in parallel
      final batchResults = await Future.wait(
        batch.map(
          (url) => getMetadata(url, forceRefresh: forceRefresh).catchError(
            (dynamic e) {
              log('Error fetching metadata for $url: $e');
              // Return an empty metadata object with the URL
              return LinkMetadata(
                originalUrl: url,
                finalUrl: url,
              );
            },
          ),
        ),
      );

      results.addAll(batchResults);
    }

    return results;
  }

  /// clears the storage caches
  /// Note: This only clears the Storage cache, not UI cache.
  static Future<void> clearStorageCache() async {
    final cache = await MetadataCacheFactory.getSharedInstance();
    await cache.clear();
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

/// Factory for creating metadata cache instances
class MetadataFlutterCacheFactory {
  /// Shared instance of the cache
  static MetadataCache? _sharedInstance;

  /// The name of the Hive box used for caching
  static const String _boxName = 'metalink_flutter_cache';

  /// Gets a shared instance of the metadata cache
  ///
  /// The shared instance uses persistent storage if available
  static Future<MetadataCache> getSharedInstance() async {
    if (_sharedInstance != null) {
      return _sharedInstance!;
    }

    // Try to get or create Hive box
    Box<String>? box;
    try {
      // Try to initialize Hive - will throw if already initialized
      try {
        await Hive.initFlutter();
      } catch (_) {
        // Hive is already initialized, which is fine
      }

      // Open the box
      box = await Hive.openBox<String>(_boxName);
    } catch (e, s) {
      // If we can't open the box, we'll use memory-only cache
      log('Error opening Hive box: $e', stackTrace: s);
    }

    _sharedInstance = MetadataCache(box: box);
    return _sharedInstance!;
  }

  /// Creates a new memory-only cache instance
  static MetadataCache createMemoryCache({
    String keyPrefix = 'metalink_cache_',
    int defaultTtlMs = 14400000, // 4 hours by default
  }) {
    return MetadataCache(
      box: null,
      keyPrefix: keyPrefix,
      defaultTtlMs: defaultTtlMs,
    );
  }

  /// Creates a new cache instance with a custom box
  static Future<MetadataCache> createWithBox({
    required String boxName,
    String keyPrefix = 'metalink_cache_',
    int defaultTtlMs = 14400000, // 4 hours by default
    String? directory,
  }) async {
    // Try to initialize Hive - will throw if already initialized
    try {
      if (!kIsWeb) {
        await Hive.initFlutter();
      } else {
        Hive.init('');
      }
    } catch (_) {
      // Hive is already initialized, which is fine
    }

    // Check if box exists and open it
    final box = await Hive.openBox<String>(boxName);

    return MetadataCache(
      box: box,
      keyPrefix: keyPrefix,
      defaultTtlMs: defaultTtlMs,
    );
  }
}
