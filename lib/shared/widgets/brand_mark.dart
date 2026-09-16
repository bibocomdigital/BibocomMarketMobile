import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 56,
    this.dark = false,
    this.circle = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  final double size;
  final bool dark;
  final bool circle;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ??
        (dark ? Colors.white : AppColors.primary);
    final fg = foregroundColor ??
        (dark ? AppColors.primary : Colors.white);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(size * 0.28),
      ),
      alignment: Alignment.center,
      child: Text(
        'B',
        style: TextStyle(
          color: fg,
          fontSize: size * 0.5,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
