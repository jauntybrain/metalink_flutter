import 'package:flutter/material.dart';
import 'package:metalink/metalink.dart';
import 'package:url_launcher/url_launcher.dart';

/// Extensions on [LinkMetadata] for Flutter-specific functionality
extension LinkMetadataExtensions on LinkMetadata {
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
}

/// Extensions on [BuildContext] for easy access to link preview utilities
extension LinkPreviewContextExtensions on BuildContext {
  /// Launches a URL from this context, returning whether the URL was launched
  Future<bool> launchUrlFromContext(String url) async {
    final uri = Uri.parse(url);
    return await canLaunchUrl(uri) && await launchUrl(uri);
  }
}
