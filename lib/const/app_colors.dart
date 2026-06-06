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
    return Theme.of(context).colorScheme.outline;
  }

  static Color surfaceOf(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color surfaceAltOf(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }

  static Color canvasOf(BuildContext context) {
    return canvasFor(Theme.of(context).brightness);
  }

  // Solid background options (light, dark) — index 0 in this list = backgroundIndex 1
  // Light: visible tinted pastels; Dark: very dark tinted
  static const List<(Color, Color)> solidBackgrounds = [
    (Color(0xFFEEF0FA), Color(0xFF111827)), // neutral
    (Color(0xFFE8F0FF), Color(0xFF0D1B2A)), // blue
    (Color(0xFFE4F0E6), Color(0xFF0A1A0E)), // green
    (Color(0xFFFFF6DC), Color(0xFF1A1500)), // yellow
    (Color(0xFFF9DCEA), Color(0xFF1A080A)), // pink
    (Color(0xFFEFDEF8), Color(0xFF130A1F)), // purple
    (Color(0xFFDAF4FA), Color(0xFF041414)), // teal
    (Color(0xFFFFF0DB), Color(0xFF1A1008)), // orange
  ];

  // Card colors paired with each solid background.
  // Light mode: ~30% lighter than background toward white — clearly brighter
  // than the canvas but still visibly tinted.
  // Dark mode: slightly lighter than the dark background (standard elevation).
  static const List<(Color, Color)> solidCardColors = [
    (Color(0xFFF3F5FC), Color(0xFF1E2840)), // neutral
    (Color(0xFFEFF5FF), Color(0xFF163040)), // blue
    (Color(0xFFECF5EE), Color(0xFF122616)), // green
    (Color(0xFFFFF9E7), Color(0xFF241E08)), // yellow
    (Color(0xFFFBE7F0), Color(0xFF241214)), // pink
    (Color(0xFFF4E8FA), Color(0xFF1C1230)), // purple
    (Color(0xFFE5F7FC), Color(0xFF081E22)), // teal
    (Color(0xFFFFF5E6), Color(0xFF241810)), // orange
  ];

  // Solid outline colors for light mode — more visible against tinted backgrounds.
  // Dark mode always uses the default outline (already visible on dark surfaces).
  static const List<Color> solidOutlinesLight = [
    Color(0xFFBEC4E0), // neutral
    Color(0xFFB0C8FF), // blue
    Color(0xFFB0D4B8), // green
    Color(0xFFE8D898), // yellow
    Color(0xFFE0ACCB), // pink
    Color(0xFFD0AEE8), // purple
    Color(0xFFA0D8E8), // teal
    Color(0xFFE8C898), // orange
  ];

  static Color solidBackgroundOf(int index, BuildContext context) {
    final (light, dark) = solidBackgrounds[index - 1];
    return isDark(context) ? dark : light;
  }

  static Color solidCardColorOf(int index, BuildContext context) {
    final (light, dark) = solidCardColors[index - 1];
    return isDark(context) ? dark : light;
  }

  static Color solidOutlineOf(int index, BuildContext context) {
    if (isDark(context)) return outlineFor(Brightness.dark);
    return solidOutlinesLight[index - 1];
  }

  /// Returns the card color for the given background index.
  /// index 0 (gradient) → default surface; index 1-8 → paired card color.
  static Color cardColorOf(int backgroundIndex, BuildContext context) {
    if (backgroundIndex == 0) return surfaceOf(context);
    return solidCardColorOf(backgroundIndex, context);
  }

  /// Returns the outline/border color for the given background index.
  /// index 0 (gradient) → default outline; index 1-8 → more visible tinted outline.
  static Color outlineColorOf(int backgroundIndex, BuildContext context) {
    if (backgroundIndex == 0) return outlineOf(context);
    return solidOutlineOf(backgroundIndex, context);
  }

  static LinearGradient backgroundGradientOf(BuildContext context) {
    return isDark(context) ? darkBackgroundGradient : backgroundGradient;
  }

  // Hero gradients paired with each solid background (light, dark).
  // index 0 in this list = backgroundIndex 1
  static const List<(LinearGradient, LinearGradient)> solidHeroGradients = [
    // neutral — same as default blue/teal
    (
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2563EB), Color(0xFF22C1C3)]),
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1D4ED8), Color(0xFF0F766E)]),
    ),
    // blue — same as default
    (
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2563EB), Color(0xFF22C1C3)]),
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1D4ED8), Color(0xFF0F766E)]),
    ),
    // green
    (
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF16A34A), Color(0xFF059669)]),
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF15803D), Color(0xFF047857)]),
    ),
    // yellow
    (
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFD97706), Color(0xFFB45309)]),
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF92400E), Color(0xFF78350F)]),
    ),
    // pink
    (
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFDB2777), Color(0xFFBE185D)]),
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF9D174D), Color(0xFF881337)]),
    ),
    // purple
    (
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)]),
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF5B21B6), Color(0xFF4C1D95)]),
    ),
    // teal
    (
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0891B2), Color(0xFF0D9488)]),
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0E7490), Color(0xFF134E4A)]),
    ),
    // orange
    (
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFEA580C), Color(0xFFD97706)]),
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF9A3412), Color(0xFF7C2D12)]),
    ),
  ];

  static LinearGradient heroGradientOf(BuildContext context) {
    return isDark(context) ? darkHeroGradient : heroGradient;
  }

  static LinearGradient heroGradientForBackground(int backgroundIndex, BuildContext context) {
    if (backgroundIndex == 0) return heroGradientOf(context);
    final isDarkMode = isDark(context);
    final (light, dark) = solidHeroGradients[backgroundIndex - 1];
    return isDarkMode ? dark : light;
  }
}
