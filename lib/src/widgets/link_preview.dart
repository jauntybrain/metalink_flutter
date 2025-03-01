import 'package:flutter/material.dart';

import '../controllers/link_preview_controller.dart';
import '../controllers/metadata_provider.dart';
import '../models/link_preview_data.dart';
import '../models/link_preview_style.dart';
import 'link_preview_builder.dart';

/// Main link preview widget that can be configured and used directly
class LinkPreview extends StatelessWidget {
  /// Creates a [LinkPreview] with the given URL and configuration.
  const LinkPreview({
    super.key,
    required this.url,
    this.controller,
    this.provider,
    this.config = const LinkPreviewConfig(),
    this.onTap,
    this.errorBuilder,
    this.loadingBuilder,
    this.previewBuilder,
  });

  /// URL to load preview for
  final String url;

  /// Optional controller for managing the preview
  final LinkPreviewController? controller;

  /// Optional metadata provider
  final MetadataProvider? provider;

  /// Configuration for the preview
  final LinkPreviewConfig config;

  /// Callback when the preview is tapped
  final VoidCallback? onTap;

  /// Builder for handling errors
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Builder for customizing the loading state
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Custom builder for the preview
  final Widget Function(BuildContext context, LinkPreviewData data)?
      previewBuilder;

  @override
  Widget build(BuildContext context) {
    if (previewBuilder != null) {
      return _CustomLinkPreview(
        url: url,
        controller: controller,
        provider: provider,
        onTap: onTap,
        errorBuilder: errorBuilder,
        loadingBuilder: loadingBuilder,
        previewBuilder: previewBuilder!,
      );
    }

    return LinkPreviewBuilder(
      url: url,
      controller: controller,
      provider: provider,
      style: config.style,
      titleMaxLines: config.titleMaxLines,
      descriptionMaxLines: config.descriptionMaxLines,
      showImage: config.showImage,
      showFavicon: config.showFavicon,
      onTap: onTap,
      handleNavigation: config.handleNavigation,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
    );
  }

  /// Creates a compact style link preview
  factory LinkPreview.compact({
    Key? key,
    required String url,
    LinkPreviewController? controller,
    MetadataProvider? provider,
    int titleMaxLines = 1,
    int descriptionMaxLines = 1,
    bool showImage = true,
    bool showFavicon = true,
    VoidCallback? onTap,
    bool handleNavigation = true,
    Widget Function(BuildContext context, Object error)? errorBuilder,
    Widget Function(BuildContext context)? loadingBuilder,
  }) {
    return LinkPreview(
      key: key,
      url: url,
      controller: controller,
      provider: provider,
      config: LinkPreviewConfig(
        style: LinkPreviewStyle.compact,
        titleMaxLines: titleMaxLines,
        descriptionMaxLines: descriptionMaxLines,
        showImage: showImage,
        showFavicon: showFavicon,
        handleNavigation: handleNavigation,
      ),
      onTap: onTap,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
    );
  }

  /// Creates a card style link preview
  factory LinkPreview.card({
    Key? key,
    required String url,
    LinkPreviewController? controller,
    MetadataProvider? provider,
    int titleMaxLines = 2,
    int descriptionMaxLines = 3,
    bool showImage = true,
    bool showFavicon = true,
    VoidCallback? onTap,
    bool handleNavigation = true,
    Widget Function(BuildContext context, Object error)? errorBuilder,
    Widget Function(BuildContext context)? loadingBuilder,
  }) {
    return LinkPreview(
      key: key,
      url: url,
      controller: controller,
      provider: provider,
      config: LinkPreviewConfig(
        style: LinkPreviewStyle.card,
        titleMaxLines: titleMaxLines,
        descriptionMaxLines: descriptionMaxLines,
        showImage: showImage,
        showFavicon: showFavicon,
        handleNavigation: handleNavigation,
      ),
      onTap: onTap,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
    );
  }

  /// Creates a large style link preview
  factory LinkPreview.large({
    Key? key,
    required String url,
    LinkPreviewController? controller,
    MetadataProvider? provider,
    int titleMaxLines = 2,
    int descriptionMaxLines = 4,
    bool showImage = true,
    bool showFavicon = true,
    VoidCallback? onTap,
    bool handleNavigation = true,
    Widget Function(BuildContext context, Object error)? errorBuilder,
    Widget Function(BuildContext context)? loadingBuilder,
  }) {
    return LinkPreview(
      key: key,
      url: url,
      controller: controller,
      provider: provider,
      config: LinkPreviewConfig(
        style: LinkPreviewStyle.large,
        titleMaxLines: titleMaxLines,
        descriptionMaxLines: descriptionMaxLines,
        showImage: showImage,
        showFavicon: showFavicon,
        handleNavigation: handleNavigation,
      ),
      onTap: onTap,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
    );
  }

  /// Creates a custom style link preview with complete control over rendering
  factory LinkPreview.custom({
    Key? key,
    required String url,
    required Widget Function(BuildContext context, LinkPreviewData data)
        builder,
    LinkPreviewController? controller,
    MetadataProvider? provider,
    VoidCallback? onTap,
    Widget Function(BuildContext context, Object error)? errorBuilder,
    Widget Function(BuildContext context)? loadingBuilder,
  }) {
    return LinkPreview(
      key: key,
      url: url,
      controller: controller,
      provider: provider,
      onTap: onTap,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      previewBuilder: builder,
    );
  }
}

/// Private widget for custom link previews
class _CustomLinkPreview extends StatefulWidget {
  const _CustomLinkPreview({
    required this.url,
    required this.previewBuilder,
    this.controller,
    this.provider,
    this.onTap,
    this.errorBuilder,
    this.loadingBuilder,
  });

  final String url;
  final LinkPreviewController? controller;
  final MetadataProvider? provider;
  final VoidCallback? onTap;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, LinkPreviewData data)
      previewBuilder;

  @override
  State<_CustomLinkPreview> createState() => _CustomLinkPreviewState();
}

class _CustomLinkPreviewState extends State<_CustomLinkPreview> {
  late LinkPreviewController _controller;
  bool _isLocalController = false;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      _controller = widget.controller!;
      if (_controller.url != widget.url) {
        _controller.setUrl(widget.url);
      }
    } else {
      _controller = LinkPreviewController(
        provider: widget.provider,
        initialUrl: widget.url,
      );
      _isLocalController = true;
    }
  }

  @override
  void didUpdateWidget(_CustomLinkPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.url != widget.url) {
      _controller.setUrl(widget.url);
    }

    // Handle controller changes
    if (oldWidget.controller != widget.controller) {
      if (_isLocalController) {
        _controller.dispose();
      }

      if (widget.controller != null) {
        _controller = widget.controller!;
        _isLocalController = false;
        if (_controller.url != widget.url) {
          _controller.setUrl(widget.url);
        }
      } else {
        _controller = LinkPreviewController(
          provider: widget.provider,
          initialUrl: widget.url,
        );
        _isLocalController = true;
      }
    }
  }

  @override
  void dispose() {
    if (_isLocalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isLoading) {
          return widget.loadingBuilder?.call(context) ??
              const CircularProgressIndicator();
        }

        if (_controller.error != null) {
          return widget.errorBuilder?.call(context, _controller.error!) ??
              const SizedBox.shrink();
        }

        if (!_controller.hasData) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: widget.onTap,
          child: widget.previewBuilder(context, _controller.data!),
        );
      },
    );
  }
}
