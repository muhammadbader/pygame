import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/app_theme.dart';

/// Glassmorphic Container Widget
/// Creates a frosted glass effect with blur and subtle gradients
class GlassContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? shadows;
  final Gradient? gradient;
  final bool showBorder;

  const GlassContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = AppTheme.radiusMedium,
    this.blur = AppTheme.glassBlur,
    this.opacity = AppTheme.glassOpacity,
    this.borderColor,
    this.borderWidth = 1.5,
    this.shadows,
    this.gradient,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ?? AppTheme.glassShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient ?? AppTheme.glassGradient,
              borderRadius: BorderRadius.circular(borderRadius),
              border: showBorder
                  ? Border.all(
                      color: borderColor ?? AppTheme.glassLight,
                      width: borderWidth,
                    )
                  : null,
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Glowing Glass Container with animated glow effect
class GlowingGlassContainer extends StatefulWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color glowColor;
  final double glowIntensity;
  final Duration animationDuration;
  final bool animate;

  const GlowingGlassContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = AppTheme.radiusMedium,
    this.glowColor = AppTheme.desertGold,
    this.glowIntensity = 1.0,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.animate = true,
  });

  @override
  State<GlowingGlassContainer> createState() => _GlowingGlassContainerState();
}

class _GlowingGlassContainerState extends State<GlowingGlassContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final glowValue = 0.7 + (_animation.value * 0.3);
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor
                    .withOpacity(0.3 * widget.glowIntensity * glowValue),
                blurRadius: 20 * widget.glowIntensity,
                spreadRadius: 2 * widget.glowIntensity,
              ),
              BoxShadow(
                color: widget.glowColor
                    .withOpacity(0.2 * widget.glowIntensity * glowValue),
                blurRadius: 40 * widget.glowIntensity,
                spreadRadius: 4 * widget.glowIntensity,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.glassGradient,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: widget.glowColor.withOpacity(0.3 * glowValue),
                    width: 2,
                  ),
                ),
                padding: widget.padding,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Ornamental Glass Card with Arabian patterns
class OrnamentalGlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool showOrnament;
  final IconData? ornamentIcon;

  const OrnamentalGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppTheme.spacingLarge),
    this.margin,
    this.showOrnament = true,
    this.ornamentIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: width,
      height: height,
      margin: margin,
      padding: EdgeInsets.zero,
      borderRadius: AppTheme.radiusLarge,
      borderColor: AppTheme.desertGold.withOpacity(0.3),
      shadows: AppTheme.goldGlow(intensity: 0.5),
      child: Stack(
        children: [
          // Content
          Padding(
            padding: padding!,
            child: child,
          ),

          // Top ornament
          if (showOrnament)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.only(top: AppTheme.spacingMedium),
                  padding: const EdgeInsets.all(AppTheme.spacingSmall),
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.goldGlow(intensity: 0.6),
                  ),
                  child: Icon(
                    ornamentIcon ?? Icons.stars_rounded,
                    color: AppTheme.deepMidnight,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Statistic Display Card with gradient and glow
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final Color glowColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingLarge,
        vertical: AppTheme.spacingMedium,
      ),
      borderRadius: AppTheme.radiusMedium,
      borderColor: glowColor.withOpacity(0.3),
      shadows: [
        BoxShadow(
          color: glowColor.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
      child: Column(
        children: [
          // Label
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: glowColor,
                size: 18,
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              Text(
                label,
                style: AppTheme.labelLarge.copyWith(
                  color: glowColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          // Value
          ShaderMask(
            shaderCallback: (bounds) => gradient.createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            ),
            child: Text(
              value,
              style: AppTheme.displayMedium.copyWith(
                color: Colors.white,
                fontSize: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
