import 'package:flutter/foundation.dart';

/// Defines the available presentation styles for link previews
enum LinkPreviewStyle {
  /// A compact horizontal style suitable for chat messages and inline content
  compact,

  /// A card style with image on top, suitable for feeds and lists
  card,

  /// A large preview style with prominent image, suitable for featured content
  large,
}

/// Configuration options for link previews
@immutable
class LinkPreviewConfig {
  /// Creates a [LinkPreviewConfig] with customization options for link previews.
  const LinkPreviewConfig({
    this.style = LinkPreviewStyle.card,
    this.maxLines = 2,
    this.titleMaxLines = 2,
    this.descriptionMaxLines = 3,
    this.animateLoading = true,
    this.enableTap = true,
    this.cacheProvider,
    this.cacheDuration = const Duration(hours: 24),
    this.proxyUrl,
    this.userAgent,
    this.handleNavigation = true,
    this.showImage = true,
    this.showFavicon = true,
  });

  /// The visual style of the link preview
  final LinkPreviewStyle style;

  /// Maximum lines for text elements (when applicable)
  final int maxLines;

  /// Maximum lines for the title
  final int titleMaxLines;

  /// Maximum lines for the description
  final int descriptionMaxLines;

  /// Whether to animate the loading state
  final bool animateLoading;

  /// Whether the preview is tappable
  final bool enableTap;

  /// Optional cache provider
  final dynamic cacheProvider;

  /// Duration to cache the preview data
  final Duration cacheDuration;

  /// Optional CORS proxy URL for web platform
  ///
  /// This is only used on web platform to bypass CORS restrictions.
  /// Example: "https://corsproxy.io/?" or "https://cors-anywhere.herokuapp.com/"
  final String? proxyUrl;

  /// User agent string to use when fetching metadata
  final String? userAgent;

  /// Whether to handle navigation when tapped
  final bool handleNavigation;

  /// Whether to show the image
  final bool showImage;

  /// Whether to show the favicon
  final bool showFavicon;

  /// Creates a copy of this [LinkPreviewConfig] with the given fields replaced
  /// with new values.
  LinkPreviewConfig copyWith({
    LinkPreviewStyle? style,
    int? maxLines,
    int? titleMaxLines,
    int? descriptionMaxLines,
    bool? animateLoading,
    bool? enableTap,
    dynamic cacheProvider,
    Duration? cacheDuration,
    String? proxyUrl,
    String? userAgent,
    bool? handleNavigation,
    bool? showImage,
    bool? showFavicon,
  }) {
    return LinkPreviewConfig(
      style: style ?? this.style,
      maxLines: maxLines ?? this.maxLines,
      titleMaxLines: titleMaxLines ?? this.titleMaxLines,
      descriptionMaxLines: descriptionMaxLines ?? this.descriptionMaxLines,
      animateLoading: animateLoading ?? this.animateLoading,
      enableTap: enableTap ?? this.enableTap,
      cacheProvider: cacheProvider ?? this.cacheProvider,
      cacheDuration: cacheDuration ?? this.cacheDuration,
      proxyUrl: proxyUrl ?? this.proxyUrl,
      userAgent: userAgent ?? this.userAgent,
      handleNavigation: handleNavigation ?? this.handleNavigation,
      showImage: showImage ?? this.showImage,
      showFavicon: showFavicon ?? this.showFavicon,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LinkPreviewConfig &&
        other.style == style &&
        other.maxLines == maxLines &&
        other.titleMaxLines == titleMaxLines &&
        other.descriptionMaxLines == descriptionMaxLines &&
        other.animateLoading == animateLoading &&
        other.enableTap == enableTap &&
        other.cacheProvider == cacheProvider &&
        other.cacheDuration == cacheDuration &&
        other.proxyUrl == proxyUrl &&
        other.userAgent == userAgent &&
        other.handleNavigation == handleNavigation &&
        other.showImage == showImage &&
        other.showFavicon == showFavicon;
  }

  @override
  int get hashCode => Object.hash(
        style,
        maxLines,
        titleMaxLines,
        descriptionMaxLines,
        animateLoading,
        enableTap,
        cacheProvider,
        cacheDuration,
        proxyUrl,
        userAgent,
        handleNavigation,
        showImage,
        showFavicon,
      );
}
