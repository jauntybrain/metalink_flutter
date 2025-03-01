import 'package:equatable/equatable.dart';
import 'package:metalink/metalink.dart';

/// UI-specific data model for link previews, built on top of [LinkMetadata]
class LinkPreviewData extends Equatable {
  /// Creates a [LinkPreviewData] from raw metadata
  const LinkPreviewData({
    required this.url,
    this.title,
    this.description,
    this.imageUrl,
    this.imageMetadata,
    this.favicon,
    this.siteName,
    this.videoUrl,
    this.audioUrl,
    this.isHtmlContent = false,
    this.extractionTimeMs,
    this.hasImage = false,
    this.timestamp,
  });

  /// Creates a [LinkPreviewData] from [LinkMetadata]
  factory LinkPreviewData.fromMetadata(LinkMetadata metadata) {
    return LinkPreviewData(
      url: metadata.finalUrl,
      title: metadata.title,
      description: metadata.description,
      imageUrl: metadata.imageMetadata?.imageUrl,
      imageMetadata: metadata.imageMetadata,
      favicon: metadata.favicon,
      siteName: metadata.siteName,
      videoUrl: metadata.videoUrl,
      audioUrl: metadata.audioUrl,
      hasImage: metadata.hasImage,
      extractionTimeMs: metadata.extractionDurationMs,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// The URL of the link
  final String url;

  /// The title of the content
  final String? title;

  /// The description or summary of the content
  final String? description;

  /// URL of the preview image
  final String? imageUrl;

  /// Detailed metadata about the preview image
  final ImageMetadata? imageMetadata;

  /// URL of the site's favicon
  final String? favicon;

  /// Name of the site
  final String? siteName;

  /// URL of the video content, if any
  final String? videoUrl;

  /// URL of the audio content, if any
  final String? audioUrl;

  /// Whether the content is HTML
  final bool isHtmlContent;

  /// Time taken to extract the metadata, in milliseconds
  final int? extractionTimeMs;

  /// Whether the link has an associated image
  final bool hasImage;

  /// Timestamp when this data was created
  final int? timestamp;

  /// Hostname of the URL
  String get hostname => Uri.parse(url).host;

  /// Display URL with some normalization
  String get displayUrl {
    final uri = Uri.parse(url);
    var display = '${uri.host}${uri.path}';
    if (display.endsWith('/')) {
      display = display.substring(0, display.length - 1);
    }
    return display;
  }

  /// Whether the link has video content
  bool get hasVideo => videoUrl != null;

  /// Whether the link has audio content
  bool get hasAudio => audioUrl != null;

  /// Whether the preview has a favicon
  bool get hasFavicon => favicon != null;

  /// Creates a copy of this [LinkPreviewData] with the given fields replaced
  /// with new values.
  LinkPreviewData copyWith({
    String? url,
    String? title,
    String? description,
    String? imageUrl,
    ImageMetadata? imageMetadata,
    String? favicon,
    String? siteName,
    String? videoUrl,
    String? audioUrl,
    bool? isHtmlContent,
    int? extractionTimeMs,
    bool? hasImage,
    int? timestamp,
  }) {
    return LinkPreviewData(
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageMetadata: imageMetadata ?? this.imageMetadata,
      favicon: favicon ?? this.favicon,
      siteName: siteName ?? this.siteName,
      videoUrl: videoUrl ?? this.videoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      isHtmlContent: isHtmlContent ?? this.isHtmlContent,
      extractionTimeMs: extractionTimeMs ?? this.extractionTimeMs,
      hasImage: hasImage ?? this.hasImage,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
        url,
        title,
        description,
        imageUrl,
        favicon,
        siteName,
        videoUrl,
        audioUrl,
        isHtmlContent,
        extractionTimeMs,
        hasImage,
        timestamp,
      ];

  @override
  bool get stringify => true;
}
