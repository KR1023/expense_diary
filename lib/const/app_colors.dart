import 'package:flutter/material.dart';

class AppColors {
  static const Color darkInk = Color(0xFFE2E8F0);
  static const Color darkMuted = Color(0xFF94A3B8);
  static const Color darkOutline = Color(0xFF263244);
  static const Color darkSurface = Color(0xFF131A27);
  static const Color darkSurfaceAlt = Color(0xFF1A2436);
  static const Color darkCanvas = Color(0xFF0B111C);

  static const Color ink = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color outline = Color(0xFFE2E8F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF4F6FB);
  static const Color canvas = Color(0xFFF7F8FC);
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF0EA5A4);
  static const Color accent = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFE11D48);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEFF4FF),
      Color(0xFFFFF4E9),
    ],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2563EB),
      Color(0xFF22C1C3),
    ],
  );

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0B1326),
      Color(0xFF162033),
    ],
  );

  static const LinearGradient darkHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1D4ED8),
      Color(0xFF0F766E),
    ],
  );

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color inkFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkInk : ink;
  }

  static Color mutedFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkMuted : muted;
  }

  static Color outlineFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkOutline : outline;
  }

  static Color surfaceFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkSurface : surface;
  }

  static Color surfaceAltFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkSurfaceAlt : surfaceAlt;
  }

  static Color canvasFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkCanvas : canvas;
  }

  static Color inkOf(BuildContext context) {
    return inkFor(Theme.of(context).brightness);
  }

  static Color mutedOf(BuildContext context) {
    return mutedFor(Theme.of(context).brightness);
  }

  static Color outlineOf(BuildContext context) {
    return outlineFor(Theme.of(context).brightness);
  }

  static Color surfaceOf(BuildContext context) {
    return surfaceFor(Theme.of(context).brightness);
  }

  static Color surfaceAltOf(BuildContext context) {
    return surfaceAltFor(Theme.of(context).brightness);
  }

  static Color canvasOf(BuildContext context) {
    return canvasFor(Theme.of(context).brightness);
  }

  static LinearGradient backgroundGradientOf(BuildContext context) {
    return isDark(context) ? darkBackgroundGradient : backgroundGradient;
  }

  static LinearGradient heroGradientOf(BuildContext context) {
    return isDark(context) ? darkHeroGradient : heroGradient;
  }
}
