import 'package:flutter/material.dart';
import 'package:metalink/metalink.dart';

/// A utility class for resolving and optimizing images from [ImageMetadata]
class ImageResolver {
  /// Generates an optimized image URL based on the provided constraints
  static String? optimizeImageUrl(
    ImageMetadata? metadata, {
    double? width,
    double? height,
    int? quality,
    BoxFit fit = BoxFit.cover,
  }) {
    if (metadata == null || metadata.imageUrl.isEmpty) {
      return null;
    }

    // Check if the image supports manipulation
    if (!metadata.canResizeWidth && !metadata.canResizeHeight) {
      return metadata.imageUrl;
    }

    // Convert double dimensions to int if provided
    final intWidth = width?.toInt();
    final intHeight = height?.toInt();

    // Calculate missing dimension if aspect ratio is available
    var calculatedWidth = intWidth;
    var calculatedHeight = intHeight;

    if (metadata.aspectRatio != null) {
      if (intWidth != null && intHeight == null) {
        calculatedHeight = (intWidth / metadata.aspectRatio!).round();
      } else if (intWidth == null && intHeight != null) {
        calculatedWidth = (intHeight * metadata.aspectRatio!).round();
      }
    }

    // Generate the URL with the resolved dimensions
    return metadata.generateUrl(
      width: calculatedWidth,
      height: calculatedHeight,
      quality: quality,
    );
  }

  /// Creates a set of responsive image URLs for different device sizes
  static List<ResponsiveImage> generateResponsiveImages(
    ImageMetadata metadata, {
    List<ResponsiveBreakpoint>? breakpoints,
  }) {
    final effectiveBreakpoints = breakpoints ?? defaultBreakpoints;
    final result = <ResponsiveImage>[];

    // Skip if no manipulation is possible
    if (!metadata.canResizeWidth && !metadata.canResizeHeight) {
      return [
        ResponsiveImage(
          url: metadata.imageUrl,
          width: metadata.width,
          height: metadata.height,
          breakpoint: null,
        ),
      ];
    }

    // Generate an image for each breakpoint
    for (final breakpoint in effectiveBreakpoints) {
      final url = metadata.generateUrl(
        width: breakpoint.width,
        height: breakpoint.height,
      );

      result.add(ResponsiveImage(
        url: url,
        width: breakpoint.width,
        height: breakpoint.height,
        breakpoint: breakpoint,
      ));
    }

    return result;
  }

  /// Default responsive breakpoints
  static const List<ResponsiveBreakpoint> defaultBreakpoints = [
    ResponsiveBreakpoint(name: 'sm', width: 320),
    ResponsiveBreakpoint(name: 'md', width: 640),
    ResponsiveBreakpoint(name: 'lg', width: 1024),
    ResponsiveBreakpoint(name: 'xl', width: 1600),
  ];

  /// Gets the most appropriate image from a set of responsive images
  /// based on the available width
  static ResponsiveImage? getBestFitImage(
    List<ResponsiveImage> images,
    double availableWidth,
  ) {
    if (images.isEmpty) {
      return null;
    }

    // Sort images by width
    final sorted = List<ResponsiveImage>.from(images)
      ..sort((a, b) => (a.width ?? 0).compareTo(b.width ?? 0));

    // Find the first image that's larger than our available width
    for (final image in sorted) {
      if ((image.width ?? 0) >= availableWidth) {
        return image;
      }
    }

    // If all images are smaller than available width, return the largest
    return sorted.last;
  }
}

/// Represents a responsive breakpoint with optional dimensions
class ResponsiveBreakpoint {
  /// Creates a [ResponsiveBreakpoint] with the given parameters.
  const ResponsiveBreakpoint({
    required this.name,
    required this.width,
    this.height,
  });

  /// Name of this breakpoint (e.g., 'sm', 'md', 'lg')
  final String name;

  /// Width for this breakpoint
  final int width;

  /// Optional height for this breakpoint
  final int? height;
}

/// Represents a responsive image with its dimensions and source breakpoint
class ResponsiveImage {
  /// Creates a [ResponsiveImage] with the given parameters.
  const ResponsiveImage({
    required this.url,
    this.width,
    this.height,
    this.breakpoint,
  });

  /// URL of the image
  final String url;

  /// Width of the image in pixels
  final int? width;

  /// Height of the image in pixels
  final int? height;

  /// The breakpoint this image was generated for
  final ResponsiveBreakpoint? breakpoint;
}
