import 'package:easy_localization/easy_localization.dart';
import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/service/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BackgroundScreen extends StatelessWidget {
  const BackgroundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 4),
                Text(
                  'settings.background.title'.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            Text(
              'settings.background.subtitle'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedOf(context),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'settings.background.section_style'.tr(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.mutedOf(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: GetIt.I<AppSettings>(),
              builder: (context, _) {
                final settings = GetIt.I<AppSettings>();
                final currentIndex = settings.backgroundIndex;
                final isDark = AppColors.isDark(context);

                return LayoutBuilder(
                  builder: (context, constraints) {
                    const columns = 4;
                    const spacing = 12.0;
                    final swatchSize =
                        (constraints.maxWidth - (columns - 1) * spacing) /
                        columns;

                    // Gradient option (index 0)
                    final gradientBg = BoxDecoration(
                      gradient:
                          isDark
                              ? AppColors.darkBackgroundGradient
                              : AppColors.backgroundGradient,
                      borderRadius: BorderRadius.circular(12),
                    );
                    // Use hardcoded surface value so the swatch always shows
                    // the correct default card color regardless of current selection.
                    final gradientCardColor = AppColors.surfaceFor(
                      isDark ? Brightness.dark : Brightness.light,
                    );

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        _BackgroundSwatch(
                          size: swatchSize,
                          backgroundDecoration: gradientBg,
                          cardColor: gradientCardColor,
                          outlineColor: AppColors.outlineOf(context),
                          label: 'settings.background.option_gradient'.tr(),
                          isSelected: currentIndex == 0,
                          onTap: () => settings.setBackgroundIndex(0),
                        ),
                        // Solid color options (index 1..N)
                        ...AppColors.solidBackgrounds.asMap().entries.map((e) {
                          final solidIndex = e.key + 1;
                          final (lightBg, darkBg) = e.value;
                          final bgColor = isDark ? darkBg : lightBg;
                          final cardColor = AppColors.solidCardColorOf(
                            solidIndex,
                            context,
                          );
                          return _BackgroundSwatch(
                            size: swatchSize,
                            backgroundDecoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            cardColor: cardColor,
                            outlineColor: AppColors.outlineOf(context),
                            isSelected: currentIndex == solidIndex,
                            onTap: () => settings.setBackgroundIndex(solidIndex),
                          );
                        }),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundSwatch extends StatelessWidget {
  const _BackgroundSwatch({
    required this.size,
    required this.backgroundDecoration,
    required this.cardColor,
    required this.outlineColor,
    required this.isSelected,
    required this.onTap,
    this.label,
  });

  final double size;
  final BoxDecoration backgroundDecoration;
  final Color cardColor;
  final Color outlineColor;
  final bool isSelected;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: size,
            height: size,
            decoration: backgroundDecoration.copyWith(
              border: Border.all(
                color: isSelected ? AppColors.primary : outlineColor,
                width: isSelected ? 2.5 : 1.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isSelected ? 9.5 : 11),
              child: Stack(
                children: [
                  // Mini card preview at the bottom
                  Positioned(
                    left: 6,
                    right: 6,
                    bottom: 7,
                    child: Container(
                      height: size * 0.28,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: outlineColor.withValues(alpha: 0.6),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                  // Selected check mark (top-right)
                  if (isSelected)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: size,
              child: Text(
                label!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color:
                      isSelected ? AppColors.primary : AppColors.mutedOf(context),
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
