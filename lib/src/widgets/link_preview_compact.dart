import 'package:flutter/material.dart';
import 'package:flutter_helper_utils/flutter_helper_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/link_preview_data.dart';
import '../themes/link_preview_theme.dart';
import 'favicon_widget.dart';
import 'image_preview.dart';

/// A compact horizontal link preview widget, suitable for chat interfaces
class LinkPreviewCompact extends StatelessWidget {
  /// Creates a [LinkPreviewCompact] with the given data.
  const LinkPreviewCompact({
    super.key,
    required this.data,
    this.titleMaxLines = 1,
    this.descriptionMaxLines = 1,
    this.showImage = true,
    this.showFavicon = true,
    this.onTap,
    this.handleNavigation = true,
  });

  /// The data to display in the preview
  final LinkPreviewData data;

  /// Maximum number of lines for the title
  final int titleMaxLines;

  /// Maximum number of lines for the description
  final int descriptionMaxLines;

  /// Whether to show the image
  final bool showImage;

  /// Whether to show the favicon
  final bool showFavicon;

  /// Callback when the preview is tapped
  final VoidCallback? onTap;

  /// Whether to handle navigation when tapped
  final bool handleNavigation;

  @override
  Widget build(BuildContext context) {
    final themeData = LinkPreviewTheme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final borderRadius = themeData.borderRadius ?? BorderRadius.circular(12.0);

    return Container(
      constraints: BoxConstraints(
        maxHeight: themeData.maxHeight ?? 100.0,
      ),
      decoration: BoxDecoration(
        color: themeData.backgroundColor ?? colorScheme.surface,
        borderRadius: borderRadius,
        border: Border.all(color: colorScheme.outline.addOpacity(0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              onTap ?? (handleNavigation ? () => _launchUrl(data.url) : null),
          child: Padding(
            padding: themeData.padding ?? const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showImage && data.imageUrl != null)
                  ClipRRect(
                    borderRadius: themeData.imageBorderRadius ??
                        BorderRadius.circular(6.0),
                    child: SizedBox(
                      width: 60.0,
                      height: 60.0,
                      child: ImagePreview(
                        imageUrl: data.imageUrl!,
                        imageMetadata: data.imageMetadata,
                        width: 60.0,
                        height: 60.0,
                      ),
                    ),
                  ),
                if (showImage && data.imageUrl != null)
                  SizedBox(width: themeData.compactSpacing ?? 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (data.title != null)
                        Text(
                          data.title!,
                          style: themeData.titleStyle ??
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          maxLines: titleMaxLines,
                          overflow: TextOverflow.ellipsis,
                        ),

                      if (data.description != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            data.description!,
                            style: themeData.descriptionStyle ??
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color:
                                          colorScheme.onSurface.addOpacity(0.7),
                                    ),
                            maxLines: descriptionMaxLines,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      // Domain and favicon
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            if (showFavicon && data.hasFavicon)
                              FaviconWidget(
                                url: data.favicon!,
                                size: themeData.faviconSize ?? 12.0,
                                backgroundColor:
                                    colorScheme.surfaceContainerHighest,
                              ),
                            if (showFavicon && data.hasFavicon)
                              const SizedBox(width: 4.0),
                            Expanded(
                              child: Text(
                                data.siteName ?? data.hostname,
                                style: themeData.siteNameStyle ??
                                    Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: colorScheme.onSurface
                                              .addOpacity(0.6),
                                        ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
