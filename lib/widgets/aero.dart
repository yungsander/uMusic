import 'dart:ui';
import 'package:material_ui/material_ui.dart';
import '../core/theme/app_theme.dart';

/// Una burbuja: posición como proporción de la pantalla (0 a 1) y diámetro en px.
class BubbleSpec {
  final double x;
  final double y;
  final double size;
  final double opacity;
  const BubbleSpec(this.x, this.y, this.size, {this.opacity = 1});
}

/// Edita esta lista para cambiar las burbujas.
const List<BubbleSpec> kBubbles = [
  BubbleSpec(0.82, 0.12, 46),
  BubbleSpec(0.92, 0.22, 18),
  BubbleSpec(0.14, 0.30, 28),
  BubbleSpec(0.70, 0.55, 64),
  BubbleSpec(0.10, 0.78, 38),
  BubbleSpec(0.85, 0.88, 22),
];

/// Fondo de ondas vectoriales con burbujas encima.
class AeroBackground extends StatelessWidget {
  final List<BubbleSpec> bubbles;
  const AeroBackground({super.key, this.bubbles = kBubbles});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const VectorWaveBackground(),
        CustomPaint(painter: _BubblePainter(bubbles)),
      ],
    );
  }
}

class _BubblePainter extends CustomPainter {
  final List<BubbleSpec> bubbles;
  const _BubblePainter(this.bubbles);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 400;

    for (final b in bubbles) {
      final c = Offset(size.width * b.x, size.height * b.y);
      final r = b.size * scale / 2;
      final rect = Rect.fromCircle(center: c, radius: r);
      final o = b.opacity;

      // Cuerpo casi transparente, más claro hacia el borde
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0x00FFFFFF),
              Color.fromRGBO(63, 184, 214, 0.10 * o),
              Color.fromRGBO(255, 255, 255, 0.45 * o),
            ],
            stops: const [0.0, 0.75, 1.0],
          ).createShader(rect),
      );

      // Borde
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = Color.fromRGBO(255, 255, 255, 0.85 * o),
      );

      // Brillo principal arriba a la izquierda
      canvas.drawOval(
        Rect.fromCenter(
          center: c.translate(-r * 0.38, -r * 0.42),
          width: r * 0.5,
          height: r * 0.28,
        ),
        Paint()..color = Color.fromRGBO(255, 255, 255, 0.9 * o),
      );

      // Reflejo suave abajo a la derecha
      canvas.drawArc(
        rect.deflate(r * 0.14),
        0.15,
        0.9,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.08
          ..strokeCap = StrokeCap.round
          ..color = Color.fromRGBO(255, 255, 255, 0.55 * o),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) =>
      oldDelegate.bubbles != bubbles;
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
        const Positioned.fill(
          child: RepaintBoundary(child: AeroBackground()),
        ),
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

/// Panel de vidrio translúcido. Con blur: false es más liviano.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool blur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.blur = true,
  });

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);

    final panel = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: shape,
        border: Border.all(color: AppColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: blur
              ? const [Color(0x55FFFFFF), Color(0x1FFFFFFF)]
              : const [Color(0xE6F4FBFD), Color(0xCCE3F4F8)],
        ),
      ),
      child: child,
    );

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
        child: blur
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: panel,
              )
            : panel,
      ),
    );
  }
}

class VectorWaveBackground extends StatelessWidget {
  const VectorWaveBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: SizedBox.expand(
        child: CustomPaint(painter: _WavePainter()),
      ),
    );
  }
}

/// Una cinta: dos bordes (curvas de Bézier con 4 puntos, en proporciones 0 a 1)
/// y muchas líneas finas interpoladas entre ellos.
class _Ribbon {
  final List<Offset> a;
  final List<Offset> b;
  final Color color;
  final int lines;
  const _Ribbon(this.a, this.b, this.color, {this.lines = 90});
}

class _WavePainter extends CustomPainter {
  const _WavePainter();

  static const List<_Ribbon> _ribbons = [
    // Cinta aqua grande, a lo largo del lado izquierdo
    _Ribbon(
      [Offset(-0.10, -0.05), Offset(-0.15, 0.45), Offset(0.20, 0.95), Offset(1.15, 1.00)],
      [Offset(0.30, -0.05), Offset(-0.05, 0.40), Offset(0.30, 0.85), Offset(1.15, 0.90)],
      Color(0xFF2DB5D6),
    ),
    // Cinta aqua interior, rodea la zona blanca
    _Ribbon(
      [Offset(0.55, -0.05), Offset(0.05, 0.20), Offset(0.15, 0.75), Offset(0.85, 1.10)],
      [Offset(1.10, 0.15), Offset(0.40, 0.15), Offset(0.25, 0.70), Offset(1.10, 0.95)],
      Color(0xFF3FB8D6),
    ),
    // Cinta verde, más fina
    _Ribbon(
      [Offset(0.80, -0.05), Offset(0.20, 0.15), Offset(0.10, 0.60), Offset(0.60, 1.10)],
      [Offset(0.95, -0.05), Offset(0.30, 0.20), Offset(0.20, 0.65), Offset(0.75, 1.10)],
      Color(0xFF6DB83A),
      lines: 60,
    ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final full = Offset.zero & size;

    // Base: aqua claro -> blanco -> verde claro
    canvas.drawRect(
      full,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC4EEF4), Color(0xFFF2FCFA), Color(0xFFDDF4C9)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(full),
    );

    // Zona blanca luminosa a la derecha
    canvas.drawRect(
      full,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.7, 0.1),
          radius: 0.8,
          colors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
        ).createShader(full),
    );

    Offset scale(Offset o) => Offset(o.dx * size.width, o.dy * size.height);

    for (final r in _ribbons) {
      for (var i = 0; i < r.lines; i++) {
        final t = i / (r.lines - 1);
        final p = List.generate(
          4,
          (k) => scale(Offset.lerp(r.a[k], r.b[k], t)!),
        );

        // Más opacas en los bordes de la cinta, casi transparentes al centro
        final edge = (2 * t - 1).abs();
        final alpha = 0.10 + 0.40 * edge * edge;

        final path = Path()
          ..moveTo(p[0].dx, p[0].dy)
          ..cubicTo(p[1].dx, p[1].dy, p[2].dx, p[2].dy, p[3].dx, p[3].dy);

        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8
            ..isAntiAlias = true
            ..color = r.color.withValues(alpha: alpha),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fila de vidrio sin desenfoque (rápida en listas) con efecto al presionar.
class GlassTile extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool highlighted;
  final double radius;
  final EdgeInsetsGeometry padding;

  const GlassTile({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.highlighted = false,
    this.radius = 22,
    this.padding = const EdgeInsets.all(10),
  });

  @override
  State<GlassTile> createState() => _GlassTileState();
}

class _GlassTileState extends State<GlassTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final hl = widget.highlighted;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(
              color: hl
                  ? AppColors.primary.withValues(alpha: 0.7)
                  : const Color(0xB3FFFFFF),
              width: hl ? 1.5 : 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: hl
                  ? const [Color(0xCCEFFBE3), Color(0x80C9EBA6)]
                  : const [Color(0xB8FFFFFF), Color(0x73FFFFFF)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F0B5C80),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}