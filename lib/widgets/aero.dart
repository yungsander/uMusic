import 'dart:ui';
import 'package:material_ui/material_ui.dart';
import '../core/theme/app_theme.dart';

/// Fondo degradado con brillo y burbujas.
class AeroBackground extends StatelessWidget {
  const AeroBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.skyTop,
            AppColors.skyMid,
            AppColors.aqua,
            AppColors.seaGreen,
          ],
          stops: [0, 0.5, 0.85, 1],
        ),
      ),
      child: CustomPaint(painter: _BubblesPainter(), size: Size.infinite),
    );
  }
}

class _BubblesPainter extends CustomPainter {
  const _BubblesPainter();

  // x, y (proporción de la pantalla) y radio
  static const List<List<double>> _bubbles = [
    [0.12, 0.18, 22],
    [0.82, 0.10, 14],
    [0.90, 0.35, 30],
    [0.20, 0.55, 12],
    [0.75, 0.70, 26],
    [0.08, 0.85, 34],
    [0.55, 0.92, 16],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Brillo de sol arriba a la derecha
    final glowRect = Rect.fromCircle(
      center: Offset(size.width * 0.85, size.height * 0.05),
      radius: size.width * 0.9,
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x66FFFFFF), Color(0x00FFFFFF)],
        ).createShader(glowRect),
    );

    for (final b in _bubbles) {
      final c = Offset(size.width * b[0], size.height * b[1]);
      final r = b[2];
      final rect = Rect.fromCircle(center: c, radius: r);

      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.4, -0.4),
            colors: [Color(0x55FFFFFF), Color(0x0DFFFFFF)],
          ).createShader(rect),
      );
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0x80FFFFFF),
      );
      canvas.drawCircle(
        c.translate(-r * 0.35, -r * 0.35),
        r * 0.18,
        Paint()..color = const Color(0xB3FFFFFF),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Scaffold con el fondo Aero detrás.
class AeroScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;

  const AeroScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: AeroBackground()),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar,
          body: body,
          bottomNavigationBar: bottomNavigationBar,
        ),
      ],
    );
  }
}

/// Panel de vidrio translúcido.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: const [
          BoxShadow(
            color: Color(0x33062E7A),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: shape,
              border: Border.all(color: AppColors.border),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x55FFFFFF), Color(0x1FFFFFFF)],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}