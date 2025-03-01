import 'package:flutter/material.dart';

import 'link_preview_theme.dart';
import 'link_preview_theme_data.dart';

/// Extensions on [BuildContext] to easily access link preview theming
extension LinkPreviewThemeExtension on BuildContext {
  /// Returns the [LinkPreviewThemeData] from the current theme.
  LinkPreviewThemeData get linkPreviewTheme => LinkPreviewTheme.of(this);

  /// Convenient access to theme properties specifically for link previews
  Color get linkPreviewBackground =>
      linkPreviewTheme.backgroundColor ?? Theme.of(this).colorScheme.surface;

  TextStyle? get linkPreviewTitleStyle => linkPreviewTheme.titleStyle;

  TextStyle? get linkPreviewDescriptionStyle =>
      linkPreviewTheme.descriptionStyle;

  TextStyle? get linkPreviewUrlStyle => linkPreviewTheme.urlStyle;

  BorderRadiusGeometry get linkPreviewBorderRadius =>
      linkPreviewTheme.borderRadius ?? BorderRadius.circular(12.0);

  double get linkPreviewElevation => linkPreviewTheme.elevation ?? 0.0;
}

/// Add theme extension methods to ThemeData
extension ThemeDataExtensions on ThemeData {
  /// Gets the link preview theme from this theme.
  LinkPreviewThemeData get linkPreviewTheme {
    return extension<LinkPreviewTheme>()?.data ??
        LinkPreviewThemeData.defaults(
          _FakeContext(this),
          colorScheme,
        );
  }
}

/// A fake context that provides just enough for the theme data to work with
class _FakeContext implements BuildContext {
  _FakeContext(this._theme);

  final ThemeData _theme;

  ThemeData get theme => _theme;

  // Implement all required BuildContext methods
  // Only minimal implementation needed for theme access
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
