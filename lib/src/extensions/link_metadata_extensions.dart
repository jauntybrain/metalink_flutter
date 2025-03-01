import 'package:flutter/material.dart';
import 'package:metalink/metalink.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/link_preview_data.dart';

/// Extensions on [LinkMetadata] for Flutter-specific functionality
extension LinkMetadataExtensions on LinkMetadata {
  /// Converts this [LinkMetadata] to [LinkPreviewData]
  LinkPreviewData toPreviewData() {
    return LinkPreviewData.fromMetadata(this);
  }

  /// Gets the primary image URL from this metadata
  String? get primaryImageUrl => imageMetadata?.imageUrl;

  /// Gets the scaled image URL if available, or the original URL otherwise
  String? getOptimizedImageUrl({int? width, int? height}) {
    if (imageMetadata == null ||
        !(imageMetadata!.canResizeWidth || imageMetadata!.canResizeHeight)) {
      return primaryImageUrl;
    }

    if (width == null && height == null) {
      return primaryImageUrl;
    }

    return imageMetadata!.generateUrl(
      width: width,
      height: height,
    );
  }

  /// Creates an [Image] widget from the primary image URL in this metadata
  Image? toImageWidget({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
    Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder,
  }) {
    final imageUrl = getOptimizedImageUrl(
      width: width?.toInt(),
      height: height?.toInt(),
    );

    if (imageUrl == null) return null;

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
    );
  }

  /// Returns a display-friendly version of the URL
  String get displayUrl {
    final uri = Uri.parse(finalUrl);
    var display = '${uri.host}${uri.path}';
    if (display.endsWith('/')) {
      display = display.substring(0, display.length - 1);
    }
    return display;
  }

  /// Returns the estimated reading time as a human-friendly string
  String get readingTimeString {
    final readingTime = contentAnalysis?.readingTimeSeconds;
    if (readingTime == null) return '';

    final minutes = (readingTime / 60).round();
    if (minutes < 1) return 'Less than 1 min read';
    if (minutes == 1) return '1 min read';
    return '$minutes mins read';
  }
}

/// Extensions on [BuildContext] for easy access to link preview utilities
extension LinkPreviewContextExtensions on BuildContext {
  /// Launches a URL from this context, returning whether the URL was launched
  Future<bool> launchUrlFromContext(String url) async {
    final uri = Uri.parse(url);
    return await canLaunchUrl(uri) && await launchUrl(uri);
  }
}
