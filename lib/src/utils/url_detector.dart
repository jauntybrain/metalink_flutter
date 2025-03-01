import 'package:flutter/foundation.dart';

/// A utility class for URL detection and manipulation
class UrlDetector {
  /// Detects URLs in text and returns all matches
  static List<UrlMatch> detectUrls(String text) {
    if (text.isEmpty) {
      return [];
    }

    final urlRegex = RegExp(
      r'(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})',
      caseSensitive: false,
    );

    final matches = urlRegex.allMatches(text);
    final result = <UrlMatch>[];

    for (final match in matches) {
      var url = match.group(0)!;

      // Ensure URL has a protocol
      if (url.startsWith('www.')) {
        url = 'https://$url';
      }

      result.add(UrlMatch(
        url: url,
        start: match.start,
        end: match.end,
      ));
    }

    return result;
  }

  /// Returns the first URL found in text, or null if no URL is found
  static String? extractFirstUrl(String text) {
    final matches = detectUrls(text);
    if (matches.isEmpty) {
      return null;
    }
    return matches.first.url;
  }

  /// Normalize a URL by ensuring it has a protocol and removing tracking parameters
  static String normalizeUrl(String url) {
    var normalized = url;

    // Ensure URL has a protocol
    if (!normalized.contains('://')) {
      normalized = 'https://$normalized';
    }

    try {
      final uri = Uri.parse(normalized);

      // Remove tracking parameters
      final filteredParams = Map<String, String>.from(uri.queryParameters);
      _removeTrackingParameters(filteredParams);

      // Remove fragment
      final cleaned = uri.removeFragment();

      // Return the cleaned URL
      if (filteredParams.isEmpty) {
        return cleaned.replace(queryParameters: {}).toString();
      } else if (filteredParams.length != uri.queryParameters.length) {
        return cleaned.replace(queryParameters: filteredParams).toString();
      }

      return cleaned.toString();
    } catch (e) {
      debugPrint('Error normalizing URL: $e');
      return url;
    }
  }

  /// Removes common tracking parameters from a query parameter map
  static void _removeTrackingParameters(Map<String, String> params) {
    // Common tracking parameters
    final trackingParams = [
      'utm_source',
      'utm_medium',
      'utm_campaign',
      'utm_term',
      'utm_content',
      'fbclid',
      'gclid',
      'dclid',
      'ref',
      'source',
      'yclid',
      'mc_cid',
      'mc_eid',
    ];

    // Remove all parameters from the list
    for (final param in trackingParams) {
      params.remove(param);
    }

    // Also remove any parameter that starts with utm_, fb_, ga_, or _
    params.removeWhere((key, _) =>
        key.startsWith('utm_') ||
        key.startsWith('fb_') ||
        key.startsWith('ga_') ||
        key.startsWith('_'));
  }

  /// Extracts the hostname from a URL
  static String getDomainFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      var host = uri.host;

      // Remove www. prefix if present
      if (host.startsWith('www.')) {
        host = host.substring(4);
      }

      return host;
    } catch (e) {
      return url;
    }
  }

  /// Detects the type of URL (social media, video, article, etc.)
  static UrlType detectUrlType(String url) {
    final normalizedUrl = url.toLowerCase();

    // Video platforms
    if (normalizedUrl.contains('youtube.com/watch') ||
        normalizedUrl.contains('youtu.be/') ||
        normalizedUrl.contains('vimeo.com/')) {
      return UrlType.video;
    }

    // Social media
    if (normalizedUrl.contains('twitter.com/') ||
        normalizedUrl.contains('x.com/') ||
        normalizedUrl.contains('facebook.com/') ||
        normalizedUrl.contains('instagram.com/') ||
        normalizedUrl.contains('linkedin.com/') ||
        normalizedUrl.contains('tiktok.com/') ||
        normalizedUrl.contains('reddit.com/')) {
      return UrlType.socialMedia;
    }

    // Image platforms
    if (normalizedUrl.contains('imgur.com/') ||
        normalizedUrl.contains('flickr.com/') ||
        normalizedUrl.contains('500px.com/') ||
        normalizedUrl.contains('unsplash.com/') ||
        normalizedUrl.contains('pexels.com/')) {
      return UrlType.image;
    }

    // E-commerce
    if (normalizedUrl.contains('amazon.') ||
        normalizedUrl.contains('ebay.') ||
        normalizedUrl.contains('etsy.com/') ||
        normalizedUrl.contains('shop') ||
        normalizedUrl.contains('product')) {
      return UrlType.product;
    }

    // Default to article
    return UrlType.article;
  }
}

/// Represents a URL match in text
class UrlMatch {
  /// Creates a [UrlMatch] with the given URL and position.
  const UrlMatch({
    required this.url,
    required this.start,
    required this.end,
  });

  /// The matched URL
  final String url;

  /// Start position in the original text
  final int start;

  /// End position in the original text
  final int end;
}

/// Represents the type of content at a URL
enum UrlType {
  /// Article or generic content
  article,

  /// Video content
  video,

  /// Image content
  image,

  /// Social media content
  socialMedia,

  /// Product or e-commerce content
  product,
}
