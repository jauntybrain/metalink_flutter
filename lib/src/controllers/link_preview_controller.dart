import 'package:flutter/foundation.dart';

import '../models/link_preview_data.dart';
import 'metadata_provider.dart';

/// Controller for managing link preview state and data loading
class LinkPreviewController extends ChangeNotifier {
  /// Creates a [LinkPreviewController] with the given provider
  LinkPreviewController({
    MetadataProvider? provider,
    String? initialUrl,
  })  : _provider = provider ?? MetadataProvider(),
        _url = initialUrl {
    if (initialUrl != null && initialUrl.isNotEmpty) {
      fetchData();
    }
  }

  /// The metadata provider
  final MetadataProvider _provider;

  /// Current URL being previewed
  String? _url;

  /// Current loading state
  bool _isLoading = false;

  /// Current error, if any
  Object? _error;

  /// Current preview data
  LinkPreviewData? _data;

  /// Gets the current URL
  String? get url => _url;

  /// Gets whether data is currently loading
  bool get isLoading => _isLoading;

  /// Gets the current error, if any
  Object? get error => _error;

  /// Gets the current preview data
  LinkPreviewData? get data => _data;

  /// Returns true if data is available
  bool get hasData => _data != null;

  /// Returns true if the preview has an image
  bool get hasImage => _data?.hasImage ?? false;

  /// Returns true if the preview has a favicon
  bool get hasFavicon => _data?.hasFavicon ?? false;

  /// Changes the URL and fetches new preview data
  Future<void> setUrl(String? url, {bool forceRefresh = false}) async {
    if (url == null || url.isEmpty || url == _url && !forceRefresh) {
      return;
    }

    _url = url;
    await fetchData(forceRefresh: forceRefresh);
  }

  /// Fetches preview data for the current URL
  Future<void> fetchData({bool forceRefresh = false}) async {
    if (_url == null || _url!.isEmpty) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _data = await _provider.getMetadata(_url!, forceRefresh: forceRefresh);
      _isLoading = false;
      _error = null;
    } catch (e) {
      _isLoading = false;
      _error = e;
      _data = null;
    }

    notifyListeners();
  }

  /// Clears the current preview data
  void clear() {
    _url = null;
    _data = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  /// Analyzes a text to find URLs and extracts the first one
  static String? extractUrlFromText(String text) {
    final urlRegex = RegExp(
      r'(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})',
      caseSensitive: false,
    );

    final match = urlRegex.firstMatch(text);
    return match?.group(0);
  }

  /// Extracts all URLs from a text
  static List<String> extractUrlsFromText(String text) {
    final urlRegex = RegExp(
      r'(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})',
      caseSensitive: false,
    );

    return urlRegex.allMatches(text).map((match) => match.group(0)!).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
