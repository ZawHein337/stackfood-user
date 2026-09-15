import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BottomNavItem extends StatefulWidget {
  final Widget icon;
  final Function? onTap;
  final bool isSelected;
  final String title;
  final bool isCart;
  const BottomNavItem({super.key, required this.icon, this.onTap, this.isSelected = false, required this.title, this.isCart = false});

  @override
  State<BottomNavItem> createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<BottomNavItem> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;
  late final Animation<double> _pop;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _glow = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _pop = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.22).chain(CurveTween(curve: Curves.easeOut)), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.22, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)), weight: 65),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = context.primary;
    return Expanded(
      child: ClipPath(
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          onTap: widget.onTap == null ? null : _handleTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: widget.isCart ? context.bgNeutralLight : null,
                  borderRadius: BorderRadius.vertical(bottom:  Radius.circular(Dimensions.radiusDefault)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 26, child: Center(
                          child: AnimatedScale(
                            scale: widget.isSelected ? 1.1 : 1.0,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutBack,
                            child: AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) => CustomPaint(
                                painter: _NavGlowPainter(value: _glow.value, color: primary),
                                child: Transform.scale(scale: _pop.value, child: child),
                              ),
                              child: widget.icon,
                            ),
                          ),
                        )),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: widget.isSelected ? context.subHeading.small.strong.overrideWith(color: context.primary) : context.subHeading.small.overrideWith(color: context.textBaseMedium),
                          child: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                  ],
                ),
              ),

              const SizedBox(height: Dimensions.paddingSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavGlowPainter extends CustomPainter {
  final double value;
  final Color color;

  const _NavGlowPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (value <= 0 || value >= 1) {
      return;
    }
    final Offset center = size.center(Offset.zero);
    const double minRadius = 20;
    const double maxRadius = 45;
    final double radius = minRadius + (maxRadius - minRadius) * value;
    final double opacity = (1 - value) * 0.85;
    final Paint paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..shader = RadialGradient(
        colors: <Color>[
          color.withValues(alpha: opacity),
          color.withValues(alpha: opacity * 0.5),
          color.withValues(alpha: 0),
        ],
        stops: const <double>[0.0, 0.35, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_NavGlowPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color;
}
