import 'package:flutter/material.dart';
import 'package:metalink/metalink.dart';

import '../themes/link_preview_theme.dart';

/// A widget that displays an optimized preview image from a URL
class ImagePreview extends StatelessWidget {
  /// Creates an [ImagePreview] with the given URL and metadata.
  const ImagePreview({
    super.key,
    required this.imageUrl,
    this.imageMetadata,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.placeholderColor,
    this.loadingBuilder,
    this.errorBuilder,
  });

  /// The URL of the image to display
  final String imageUrl;

  /// Optional metadata for the image
  final ImageMetadata? imageMetadata;

  /// Width of the image
  final double? width;

  /// Height of the image
  final double? height;

  /// Border radius for the image
  final BorderRadiusGeometry? borderRadius;

  /// How the image should be inscribed into the box
  final BoxFit fit;

  /// Color to use for the placeholder
  final Color? placeholderColor;

  /// Builder for customizing the loading state
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;

  /// Builder for handling errors
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    final linkPreviewTheme = LinkPreviewTheme.of(context);
    final effectiveBorderRadius = borderRadius ??
        linkPreviewTheme.imageBorderRadius ??
        BorderRadius.circular(8.0);

    // Try to get an optimized image URL if we have metadata
    final optimizedUrl = _getOptimizedImageUrl();

    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: Image.network(
        optimizedUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: loadingBuilder ?? _defaultLoadingBuilder,
        errorBuilder: errorBuilder ?? _defaultErrorBuilder,
      ),
    );
  }

  Widget _defaultLoadingBuilder(
      BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) {
      return child;
    }

    final linkPreviewTheme = LinkPreviewTheme.of(context);
    final effectivePlaceholderColor = placeholderColor ??
        linkPreviewTheme.imagePlaceholderColor ??
        Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      width: width,
      height: height,
      color: effectivePlaceholderColor,
      child: Center(
        child: loadingProgress.expectedTotalBytes != null
            ? CircularProgressIndicator(
                value: loadingProgress.cumulativeBytesLoaded /
                    (loadingProgress.expectedTotalBytes ?? 1),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }

  Widget _defaultErrorBuilder(
      BuildContext context, Object error, StackTrace? stackTrace) {
    final linkPreviewTheme = LinkPreviewTheme.of(context);
    final effectivePlaceholderColor = placeholderColor ??
        linkPreviewTheme.imagePlaceholderColor ??
        Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      width: width,
      height: height,
      color: effectivePlaceholderColor,
      child: const Center(
        child: Icon(Icons.broken_image_outlined),
      ),
    );
  }

  String _getOptimizedImageUrl() {
    // If we have metadata with manipulation capabilities, try to optimize the image
    if (imageMetadata != null &&
        (imageMetadata!.canResizeWidth || imageMetadata!.canResizeHeight)) {
      // Calculate dimensions based on the widget's size
      final targetWidth = width?.toInt();
      final targetHeight = height?.toInt();

      // Generate an optimized URL
      return imageMetadata!.generateUrl(
        width: targetWidth,
        height: targetHeight,
      );
    }

    // Otherwise use the original URL
    return imageUrl;
  }
}
