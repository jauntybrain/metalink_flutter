import 'package:flutter/material.dart';
import 'package:flutter_helper_utils/flutter_helper_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/link_preview_data.dart';
import '../themes/link_preview_theme.dart';
import 'favicon_widget.dart';
import 'image_preview.dart';

/// A card-style link preview widget
class LinkPreviewCard extends StatelessWidget {
  /// Creates a [LinkPreviewCard] with the given data.
  const LinkPreviewCard({
    super.key,
    required this.data,
    this.titleMaxLines = 2,
    this.descriptionMaxLines = 3,
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

    // Default border radius from theme or fallback
    final borderRadius =
        themeData.borderRadius ?? BorderRadiusDirectional.circular(12.0);

    return Card(
      elevation: themeData.elevation ?? 0.0,
      shape: themeData.cardShape ??
          RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: BorderSide(color: colorScheme.outline.addOpacity(0.2)),
          ),
      clipBehavior: Clip.antiAlias,
      color: themeData.backgroundColor ?? colorScheme.surface,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap ?? (handleNavigation ? () => _launchUrl(data.url) : null),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showImage && data.imageUrl != null)
              ImagePreview(
                imageUrl: data.imageUrl!,
                imageMetadata: data.imageMetadata,
                height: themeData.imageHeight ?? 150.0,
                width: double.infinity,
                borderRadius: BorderRadius.only(
                  topRight:
                      borderRadius.resolve(context.directionality).topRight,
                  topLeft: borderRadius.resolve(context.directionality).topLeft,
                ),
              ),
            Padding(
              padding: themeData.contentPadding ?? const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data.title != null)
                    Text(
                      data.title!,
                      style: themeData.titleStyle ??
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                      maxLines: titleMaxLines,
                      overflow: TextOverflow.ellipsis,
                    ),

                  if (data.title != null && data.description != null)
                    const SizedBox(height: 8.0),

                  if (data.description != null)
                    Text(
                      data.description!,
                      style: themeData.descriptionStyle ??
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.addOpacity(0.7),
                              ),
                      maxLines: descriptionMaxLines,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 8.0),

                  // Domain and favicon
                  Row(
                    children: [
                      if (showFavicon && data.hasFavicon)
                        FaviconWidget(
                          url: data.favicon!,
                          size: themeData.faviconSize ?? 16.0,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                        ),
                      if (showFavicon && data.hasFavicon)
                        const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          data.siteName ?? data.hostname,
                          style: themeData.siteNameStyle ??
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color:
                                        colorScheme.onSurface.addOpacity(0.6),
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
