import 'package:flutter/material.dart';

import '../controllers/link_preview_controller.dart';
import '../controllers/metadata_provider.dart';
import '../models/link_preview_data.dart';
import '../models/link_preview_style.dart';
import 'link_preview_card.dart';
import 'link_preview_compact.dart';
import 'link_preview_large.dart';
import 'link_preview_skeleton.dart';

/// A builder widget for creating link previews from a URL
class LinkPreviewBuilder extends StatefulWidget {
  /// Creates a [LinkPreviewBuilder] that extracts metadata from the given URL.
  const LinkPreviewBuilder({
    super.key,
    required this.url,
    this.controller,
    this.provider,
    this.style = LinkPreviewStyle.card,
    this.titleMaxLines = 2,
    this.descriptionMaxLines = 3,
    this.showImage = true,
    this.showFavicon = true,
    this.onTap,
    this.handleNavigation = true,
    this.errorBuilder,
    this.loadingBuilder,
  });

  /// URL to load preview for
  final String url;

  /// Optional controller for managing the preview
  final LinkPreviewController? controller;

  /// Optional metadata provider
  final MetadataProvider? provider;

  /// Style of the preview
  final LinkPreviewStyle style;

  /// Maximum number of lines for the title
  final int titleMaxLines;

  /// Maximum number of lines for the description
  final int descriptionMaxLines;

  /// Whether to show the image in the preview
  final bool showImage;

  /// Whether to show the favicon in the preview
  final bool showFavicon;

  /// Callback when the preview is tapped
  final VoidCallback? onTap;

  /// Whether to handle navigation when tapped
  final bool handleNavigation;

  /// Builder for handling errors
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Builder for customizing the loading state
  final Widget Function(BuildContext context)? loadingBuilder;

  @override
  State<LinkPreviewBuilder> createState() => _LinkPreviewBuilderState();
}

class _LinkPreviewBuilderState extends State<LinkPreviewBuilder> {
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
  void didUpdateWidget(LinkPreviewBuilder oldWidget) {
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
              LinkPreviewSkeleton(style: widget.style);
        }

        if (_controller.error != null) {
          return widget.errorBuilder?.call(context, _controller.error!) ??
              const SizedBox.shrink();
        }

        if (!_controller.hasData) {
          return const SizedBox.shrink();
        }

        return _buildPreview(_controller.data!);
      },
    );
  }

  Widget _buildPreview(LinkPreviewData data) {
    switch (widget.style) {
      case LinkPreviewStyle.compact:
        return LinkPreviewCompact(
          data: data,
          titleMaxLines: widget.titleMaxLines,
          descriptionMaxLines: widget.descriptionMaxLines,
          showImage: widget.showImage,
          showFavicon: widget.showFavicon,
          onTap: widget.onTap,
          handleNavigation: widget.handleNavigation,
        );
      case LinkPreviewStyle.large:
        return LinkPreviewLarge(
          data: data,
          titleMaxLines: widget.titleMaxLines,
          descriptionMaxLines: widget.descriptionMaxLines,
          showImage: widget.showImage,
          showFavicon: widget.showFavicon,
          onTap: widget.onTap,
          handleNavigation: widget.handleNavigation,
        );
      case LinkPreviewStyle.card:
      default:
        return LinkPreviewCard(
          data: data,
          titleMaxLines: widget.titleMaxLines,
          descriptionMaxLines: widget.descriptionMaxLines,
          showImage: widget.showImage,
          showFavicon: widget.showFavicon,
          onTap: widget.onTap,
          handleNavigation: widget.handleNavigation,
        );
    }
  }
}
