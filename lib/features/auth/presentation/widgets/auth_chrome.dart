import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AuthBrandMark extends StatelessWidget {
  const AuthBrandMark({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent, width: 3),
      ),
      alignment: Alignment.center,
      child: Text(
        'B',
        style: TextStyle(
          color: AppColors.accent,
          fontSize: size * 0.47,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class AuthAuraPainter extends CustomPainter {
  const AuthAuraPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final right = Paint()..color = const Color(0xFF163552);
    final rightPath = Path()
      ..moveTo(size.width * 0.55, 0)
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.18,
        size.width * 0.92,
        size.height * 0.42,
        size.width,
        size.height * 0.7,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(rightPath, right);

    final left = Paint()..color = const Color(0xFF122C48);
    final leftPath = Path()
      ..moveTo(0, size.height * 0.15)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.05,
        size.width * 0.32,
        size.height * 0.45,
        size.width * 0.18,
        size.height * 0.85,
      )
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(leftPath, left);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
