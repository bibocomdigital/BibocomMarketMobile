import 'package:flutter/material.dart';

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final length = size.shortestSide;
    final bounds = Offset.zero & Size.square(length);
    final center = bounds.center;
    final stroke = length / 4.5;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    final arcBounds = bounds.deflate(stroke / 2);

    void arc(double start, double sweep, Color color) {
      paint.color = color;
      canvas.drawArc(arcBounds, start, sweep, false, paint);
    }

    arc(3.5, 2.0, const Color(0xFFEA4335));
    arc(2.45, 1.05, const Color(0xFFFBBC05));
    arc(0.95, 1.5, const Color(0xFF34A853));
    arc(-0.2, 1.15, const Color(0xFF4285F4));

    canvas.drawRect(
      Rect.fromLTWH(
        center.dx,
        center.dy - stroke / 2,
        bounds.right - center.dx + 0.5,
        stroke,
      ),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
