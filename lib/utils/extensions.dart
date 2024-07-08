import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension TypographyUtils on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textGorditasTheme =>
      GoogleFonts.gorditasTextTheme(theme.textTheme);

  ColorScheme get colors => theme.colorScheme;

  TextStyle? get gorditasTitle => textGorditasTheme.titleMedium?.copyWith(
        color: colors.onSurface,
      );

  TextTheme get gorditasTitle1 => textGorditasTheme.copyWith();

  TextStyle? get gorditasHeadline => textGorditasTheme.headlineMedium?.copyWith(
        color: colors.onSurface,
      );

  TextStyle? get gorditasDisplay => textGorditasTheme.displayMedium?.copyWith(
        color: colors.onSurface,
      );

  TextStyle? get gorditasBody => textGorditasTheme.bodyMedium?.copyWith(
        color: colors.onSurface,
      );
}
