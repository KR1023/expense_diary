import 'package:expense_diary/service/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:get_it/get_it.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool useSafeArea;

  const AppBackground({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.useSafeArea = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    final safeContent = useSafeArea ? SafeArea(child: content) : content;

    return AnimatedBuilder(
      animation: GetIt.I<AppSettings>(),
      child: safeContent,
      builder: (context, child) {
        final bgIndex = GetIt.I<AppSettings>().backgroundIndex;
        final isGradient = bgIndex == 0;
        final isDark = AppColors.isDark(context);

        final BoxDecoration decoration;
        if (isGradient) {
          decoration = BoxDecoration(
            gradient: AppColors.backgroundGradientOf(context),
          );
        } else {
          decoration = BoxDecoration(
            color: AppColors.solidBackgroundOf(bgIndex, context),
          );
        }

        final cardColor = AppColors.cardColorOf(bgIndex, context);
        final outlineColor = AppColors.outlineColorOf(bgIndex, context);

        return Container(
          decoration: decoration,
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                surface: cardColor,
                surfaceContainerHighest: cardColor,
                outline: outlineColor,
              ),
              cardTheme: Theme.of(context).cardTheme.copyWith(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: outlineColor),
                ),
              ),
              inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
                fillColor: cardColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: outlineColor),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: outlineColor),
                ),
              ),
            ),
            child: Stack(
            children: [
              // Glow bubbles stay in the tree to keep TweenAnimationBuilder's
              // position stable (index 2). They fade when switching to solid.
              Positioned(
                top: -40,
                right: -30,
                child: AnimatedOpacity(
                  opacity: isGradient ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _GlowBubble(
                    size: 160,
                    color: AppColors.primary.withValues(
                      alpha: isDark ? 0.18 : 0.12,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -60,
                left: -30,
                child: AnimatedOpacity(
                  opacity: isGradient ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _GlowBubble(
                    size: 200,
                    color: AppColors.accent.withValues(
                      alpha: isDark ? 0.18 : 0.12,
                    ),
                  ),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 14 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: child,
              ),
            ],
          ),
          ),
        );
      },
    );
  }
}


class _GlowBubble extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowBubble({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
