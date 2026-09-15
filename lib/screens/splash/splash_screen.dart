import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final splashReadyProvider = StateProvider<bool>((ref) => false);

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _hold = Duration(milliseconds: 2500);

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(_hold, () {
      if (!mounted) return;
      ref.read(splashReadyProvider.notifier).state = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.primary),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.34,
                width: double.infinity,
                child: const CustomPaint(painter: _SplashWavePainter()),
              ),
            ),
            const SafeArea(
              child: Column(
                children: [
                  Spacer(flex: 5),
                  _SplashMark(),
                  SizedBox(height: 22),
                  Text(
                    'Bibo Market',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Espace Commerçant',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFD5DEE8),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Vendez plus, plus loin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(flex: 7),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashMark extends StatelessWidget {
  const _SplashMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.45),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        'B',
        style: TextStyle(
          color: Colors.white,
          fontSize: 44,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _SplashWavePainter extends CustomPainter {
  const _SplashWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final back = Paint()..color = const Color(0xFF173A58);
    final backPath = Path()
      ..moveTo(0, height * 0.58)
      ..cubicTo(
        width * 0.22,
        height * 0.28,
        width * 0.42,
        height * 0.86,
        width * 0.68,
        height * 0.52,
      )
      ..cubicTo(
        width * 0.86,
        height * 0.28,
        width * 0.94,
        height * 0.40,
        width,
        height * 0.36,
      )
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    canvas.drawPath(backPath, back);

    final front = Paint()..color = const Color(0xFF1E4D6C);
    final frontPath = Path()
      ..moveTo(0, height * 0.78)
      ..cubicTo(
        width * 0.20,
        height * 0.52,
        width * 0.40,
        height * 0.98,
        width * 0.64,
        height * 0.70,
      )
      ..cubicTo(
        width * 0.84,
        height * 0.46,
        width * 0.93,
        height * 0.58,
        width,
        height * 0.54,
      )
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    canvas.drawPath(frontPath, front);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
